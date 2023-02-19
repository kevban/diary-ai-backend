import 'package:dart_openai/openai.dart';
import 'package:diary_ai_backend/models/character.dart';
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
For the following characters, list 15 distinct characteristics, relationships, or facts:
COMPLETION:
Garen, from league of legends:
-is Champion of Demacia
-Wields a massive sword called "Justice"
-Is the younger half-brother of Lux, another champion from Demacia
-Is a member of the Dauntless Vanguard, an elite military unit within Demacia's armed forces
-Possesses high durability and defense, making him an effective tank
-Has the ability to spin with his sword, dealing damage to enemies around him
-Is capable of executing low-health enemies with his ultimate ability, "Demacian Justice"
-Is known for his catchphrase, "Demacia!"
-Has a strong sense of duty and loyalty to his kingdom and people
-Is often portrayed as a paragon of justice and honor, sometimes to the point of being naive or inflexible
-Has a rivalry with the Noxian champion Darius, who represents a more brutal and ruthless philosophy of combat
-Has a close relationship with his fellow Demacian champion, Jarvan IV, who is also a member of the Dauntless Vanguard and the prince of Demacia
-Has a romantic relationship with Katarina, a Noxian assassin who is typically portrayed as his enemy
-Has a strong belief in the power of physical strength and martial prowess, often eschewing magic or other forms of combat
-Has a striking visual design, including his armor, helmet, and flowing red cape
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
      prompt: '$charPrompt$charName, $charDesc:',
      maxTokens: 450,
      temperature: 0,
      frequencyPenalty: 0.5,
      n: 1,
      stop: [':'],
      echo: false,
    );
    final vocabCompletion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt: '$vocabPrompt$charName, $charDesc:',
      maxTokens: 20,
      temperature: 0,
      n: 1,
      stop: [':'],
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
    Character character,
    int sequence,
    String topic,
    String userName,
    String? userResponse,
    String? prevQuestion,
  ) async {
    OpenAI.apiKey = Env.apiKey;
    final random = Random();
    final reference = character
        .characteristics[random.nextInt(character.characteristics.length)];
    final userResponsePrompt =
        (userResponse != null) ? 'User: $userResponse\n' : '';
    final prevQuestionPrompt =
        (prevQuestion != null) ? '${character.name}: $prevQuestion\n' : '';
    var instructPrompt = '''
(${character.name}'s instruction is to greet User and ask a question about $topic, with reference to ${character.name} $reference)
''';
    final toplevelPrompt = '''
PROMPT:
A conversation between ${character.name}(${character.desc}) and User. ${character.name} will follow ${character.name}'s instructions shown in brackets. Address user by their name, $userName. ${character.name} always uses ${character.vocab} vocabulary.

COMPLETION:
''';

    switch (sequence) {
      case 0: // when conversation starts
        instructPrompt = '''
(${character.name}'s instruction is to greet User and ask a question about $topic, with reference to ${character.name} $reference)
${character.name}:
''';
        break;
      case 1: // asking question about the topic
        instructPrompt = '''
(${character.name}'s instruction is to comment on what user said, and ask a question about $topic, with reference to ${character.name} $reference)
${character.name}:''';
        break;
      case 2: // asking follow up question
        instructPrompt = '''
(${character.name}'s instruction is to comment on what user said, and ask a follow up question relevant to the User, with reference to ${character.name} $reference)
${character.name}:''';
        break;
      case 3: // asking if there is anything else
        instructPrompt = '''
(${character.name}'s instruction is to comment on what user said, and ask if there is anything else for the day, with reference to ${character.name} $reference)
${character.name}:''';
        break;
      case 4: // responding ending the conversation
        instructPrompt = '''
(${character.name}'s instruction is do the following with reference to ${character.name} $reference: if the user said if there is nothing else, say fareware to User and end the conversation. Otherwise, comment on what user said, and ask if there is anything else for the day.)
${character.name}:''';
        break;
      default:
        break;
    }
    final completion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      prompt:
          '$toplevelPrompt$userResponsePrompt$prevQuestionPrompt$instructPrompt',
      maxTokens: 100,
      temperature: 0.8,
      frequencyPenalty: 0.3,
      n: 1,
      stop: ['User'],
      echo: false,
    );

    return [
      completion.choices.first.text,
      '$toplevelPrompt$userResponsePrompt$prevQuestionPrompt$instructPrompt'
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
