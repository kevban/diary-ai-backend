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
PROMPT:
For the following characters, list (n) distinct characteristics, relationships, or facts:
COMPLETION:
Garen, from league of legends (5):
-is Champion of Demacia
-wields a massive sword called "Justice"
-is the younger half-brother of Lux, another champion from Demacia
-is a member of the Dauntless Vanguard, an elite military unit within Demacia's armed forces
-is known for his catch-phrase "Demacia!"

Tony Stark, from Marvel (6):
-is a genius, billionaire, playboy philanthropist"
-is the inventor of the Iron Man suit
-is the close friend of James Rhodes, the War Machine",
-has romantic relationship with Pepper Potts",
-is a mentor and quasi-father figure to Peter Parker, the Spiderman,
-possesses a sarcastic wit and dry sense of humor ",

''';
    const vocabPrompt = '''
For the following characters, describe their vocabulary style:

Elon Musk: Technical Jargon
Snake, from Metal Gear Solid:tactical military language
Mario, from Super Mario Bros:informal interjection
''';
    OpenAI.apiKey = Env.apiKey;
    final charCompletion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt: '$charPrompt$charName, $charDesc (12):',
      maxTokens: 450,
      temperature: 0,
      frequencyPenalty: 0.5,
      n: 1,
      stop: ['\n\n'],
      echo: false,
      
    );
    final vocabCompletion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt: '$vocabPrompt$charName, $charDesc:',
      maxTokens: 20,
      temperature: 0,
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
    String vocab,
    String reference,
    String sequence,
    String topic,
    String userName,
    String? prevConversation,
  ) async {
    OpenAI.apiKey = Env.apiKey;
    final prevQuestionPrompt =
        (prevConversation != '') ? '$charName: $prevConversation\n' : '';
    var instructPrompt = '''
($charName's instruction is to greet User with reference to $charName $reference, and ask a question about $topic)
''';
    final toplevelPrompt = '''
PROMPT:
A conversation between $charName($charDesc) and User. $charName will follow $charName's instructions shown in brackets. Address User by their name, $userName. $charName always uses $vocab vocabulary.

COMPLETION:
''';

    switch (sequence) {
      case 'GREET': // when conversation starts
        instructPrompt = '''
($charName's instruction is to greet User and make remarks that show $charName $reference. Then, ask a question about $topic.)
$charName:
''';
        break;
      case 'ASK': // asking question about the topic
        instructPrompt = '''
($charName's instruction is to comment on what User said and make remarks that show $charName $reference. Then, ask a question about $topic.)
$charName:''';
        break;
      case 'FOLLOW_UP': // asking follow up question
        instructPrompt = '''
($charName's instruction is to comment on what User said and make remarks that show $charName $reference. Then, ask a follow up question to User's statement.)
$charName:''';
        break;
      case 'ANYTHING_ELSE': // asking if there is anything else
        instructPrompt = '''
($charName's instruction is to comment on what User said and make remarks that show $charName $reference. Then, ask if there is anything else for the day.)
$charName:''';
        break;
      case 'END': // responding ending the conversation
        instructPrompt = '''
($charName's instruction is do the following: if User added new information, comment on what User said, and ask if there is anything else for the day. Otherwise, reference $charName $reference, say fareware to User, and add ENDOFCONV at the end to signal the end of conversation.)
$charName:''';
        break;
      default:
        break;
    }
    final completion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt:
          '$toplevelPrompt$prevQuestionPrompt$instructPrompt',
      maxTokens: 100,
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
      String diaryPrompt, String userName,) async {
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
