import 'package:dart_openai/openai.dart';
import 'package:diary_ai_backend/classes/character.dart';
import 'package:diary_ai_backend/env/env.dart';
import 'dart:math';

final String davinciModelName = "text-davinci-003";
final String curieModelNamee = "text-curie-001";

class OpenAIAPI {
/*
  ------------------------------------------------------------------------------
  This function creates a new AI character
  ------------------------------------------------------------------------------
  */
  static Future<Character> characterCompletion(
    String charName,
    String charDesc,
  ) async {
    const charPrompt = '''
Describe things that would constantly appear in the following character's speech:

8 things for Mario, from Super Mario Bros:
-exclamations such as "Yahoo!", "Mamma Mia!", and "It's-a me, Mario!"
-phrases related to adventure and exploration such as "Let's-a go!" and "Here we go!"
-references to his brother Luigi such as "Luigi, I'm-a coming!" and "Luigi, are you ready?"
-expressions of joy such as "Wahoo!" and "Woohoo!"
-references to Princess Peach such as "Ohhh, Princess Peach!" and "The Princess is in another castle!"
-references to his enemies such as "Bowser, you fiend!" and "Take that, Koopa Troopa!"
-comments about his size such as "Look at me, I'm so tiny!" and "I'm just a little guy!"
-references to his Italian heritage such as "Mamma Mia!", "Ciao!", and "Buon giorno!"

4 things for Donald Trump, president of U.S.:
-catchphrases such as "We will make America great again!", "build a wall", and  "Fake news!"
-expressions of patriotism such as "God bless America!" and "America is the greatest nation on Earth!"
-references to his presidential accomplishments such as "I have done more in my first term than any other president in history!" and "Nobody has ever done what I have done for the black community"
-adjectives such as "tremendous", "huge", and "unprecedented"

''';
final vocabPrompt = '''
For the following characters, describe their how they talk:

Elon Musk, entrepreneur, always has a confident and ambitious attitude and constantly uses technical jargons.
Nagisa, from Clannad, always has a polite and humble attitude and constantly uses poetic representations.
Mario, from Super Mario Bros, always has an upbeat and enthusiastic attitude and constantly uses catchphrases.
Donald Trump, U.S. president, always has a brash and assertive attitude and constantly uses bombastic language.
$charName, $charDesc, always
''';
    OpenAI.apiKey = Env.apiKey;
    final charCompletion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt: '${charPrompt}12 things for $charName, $charDesc:',
      maxTokens: 450,
      temperature: 0,
      frequencyPenalty: 0.5,
      n: 1,
      stop: ['\n\n'],
      echo: false,
    );
    final vocabCompletion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt: vocabPrompt,
      maxTokens: 450,
      temperature: 0,
      frequencyPenalty: 0.5,
      n: 1,
      stop: ['\n'],
      echo: false,
    );
    final characteristicsStr = charCompletion.choices.first.text;
    final vocabStr = vocabCompletion.choices.first.text;
    return Character(
      charName,
      charDesc,
      vocabStr,
      characteristicsStr.split('\n-'),
    );
  }

/*
  ------------------------------------------------------------------------------
  This function generates the next response of an AI character
  ------------------------------------------------------------------------------
  */
  static Future<List<String>> responseCompletion(
    String charName,
    String charDesc,
    String charVocab,
    String reference,
    String sequence,
    String topic,
    String userName,
    String? prevConversation,
  ) async {
    OpenAI.apiKey = Env.apiKey;
    var prevQuestionPrompt =
        (prevConversation != '') ? '$charName: $prevConversation\n' : '';
    var instructPrompt = '''
($charName's instruction is to greet User with reference to $charName $reference, and ask a question about $topic)
''';
    final toplevelPrompt = '''
Conversation between User and AI pretending to be $charName, $charDesc. AI will follow instructions in {}. AI will always include $reference in its speech. User's name is $userName. AI always $charVocab. AI cannot have more than one question in its speech.
''';

    switch (sequence) {
      case 'GREET': // when conversation starts
        instructPrompt = '''
{Greet using over 30 words, and ask a follow up question about User's day.}
AI:''';
        break;
      case 'ASK': // asking question about the topic
        instructPrompt = '''
{Comment using over 30 words and move on to ask a single question about $topic, }
AI:''';
        break;
      case 'FOLLOW_UP': // asking follow up question
        instructPrompt = '''
{Comment using over 30 words, and ask a single follow up question about $topic,}
AI:''';
        break;
      case 'ANYTHING_ELSE': // asking if there is anything else
        instructPrompt = '''
{Comment using over 30 words, and move on to ask if there is anything else for the day}
AI:''';
        break;
      case 'END': // responding ending the conversation
        instructPrompt = '''
{If user is ending the conversation, e.g. "nothing else", end the conversation and include ENDOFCONV at the end to signal conversation is over. Otherwise, comment and ask if there is anything else. Use over 30 words}
AI:''';
        break;
      default:
        break;
    }
    final completion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt: '$toplevelPrompt$prevQuestionPrompt$instructPrompt',
      maxTokens: 300,
      temperature: 0.8,
      frequencyPenalty: 0.3,
      n: 1,
      stop: ['User'],
      echo: false,
    );

    return [
      completion.choices.first.text,
      '$toplevelPrompt$prevQuestionPrompt$instructPrompt'
    ];
  }

  /*
  ------------------------------------------------------------------------------
  This function extracts key information from an AI conversation
  ------------------------------------------------------------------------------
  */
  static Future<List<String>> extractionCompletion(
      String conversation, List<String> topics, String charName) async {
    OpenAI.apiKey = Env.apiKey;
    final topicStr = topics.join(', ');
    final prompt = '''
PROMPT:
${conversation}Extract detailed information about $topicStr, without mentioning the conversation with $charName.

COMPLETION:
${topics[0]}:''';
    final completion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt: prompt,
      maxTokens: 100,
      temperature: 0,
      frequencyPenalty: 0.3,
      n: 1,
      stop: ['ENDOFEX'],
      echo: false,
    );
    return ['${topics[0]}:${completion.choices.first.text}', prompt];
  }

  /*
  ------------------------------------------------------------------------------
  This function generates a diary using using a prompt
  ------------------------------------------------------------------------------
  */
  static Future<List<String>> diaryCompletion(
    String diaryPrompt,
    String userName,
  ) async {
    OpenAI.apiKey = Env.apiKey;
    final prompt = '''
PROMPT:
Write a 300-word diary entry for $userName(User). The diary should only contain factual information from below:
$diaryPrompt
COMPLETION:
Dear Diary,
''';
    final completion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt: prompt,
      maxTokens: 350,
      temperature: 0.8,
      frequencyPenalty: 0.3,
      n: 1,
      stop: ['Dear Diary'],
      echo: false,
    );
    return [completion.choices.first.text, prompt];
  }
}
