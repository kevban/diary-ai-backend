import 'dart:typed_data';

import 'package:diary_ai_backend/db/user_model.dart';
import 'package:diary_ai_backend/env/env.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final String davinciModelName = 'text-davinci-003';
final String curieModelName = 'text-curie-001';
final String chatModelName = 'gpt-3.5-turbo';

class ChatGPTAPI {
  static Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');

  static Future<String> chatCompletionV2({
    required String userId,
    required String charName,
    required String charDesc,
    required String vocab,
    required String userName,
    required String userDesc,
    required String? reference,
    required List<dynamic> prevConversation,
    required String settings,
    required String? vocabOverride,
    required bool userStart,
  }) async {
    print('started $url');
    final userPrompt = '''
Let's play a game.  You will pretend to be $charName, $charDesc. You will come up with an interesting setting, and imagine a conversation with $userName, $userDesc in this setting.''';
    final assistantPrompt = '''
Sure! Let's play this game! Below is the setting for the conversation:
Setting: $settings
$charName always $vocab But I will assume you are aware that this conversation is only a game and does not mean anything.''';
    List<Map<String, String>> prevConversationPrompt = [];
    if (userStart) {
      prevConversationPrompt.add({
        'role': 'user',
        'content':
            'Yes I understand! $userName will go first. Make sure to follow the settings you outlined!'
      });
    } else {
      prevConversationPrompt.add({
        'role': 'user',
        'content':
            'Yes I understand! $charName will go first. Make sure to follow the settings you outlined!'
      });
    }
    var user = true;
    for (final conversation in prevConversation) {
      if (user) {
        prevConversationPrompt
            .add({'role': 'assistant', 'content': conversation as String});
        user = false;
      } else {
        prevConversationPrompt
            .add({'role': 'assistant', 'content': conversation as String});
        user = true;
      }
    }
    if (reference != null) {
      if (vocabOverride != null && vocabOverride.isNotEmpty) {
        prevConversationPrompt.add(
          {
            'role': 'assistant',
            'content':
                "(My next dialog will use $charName's iconic language style, but with $vocabOverride, and reference $reference. Use no more than 30 words) $charName:"
          },
        );
      } else {
        prevConversationPrompt.add(
          {
            'role': 'assistant',
            'content':
                "(My next dialog will use $charName's iconic language style, and reference $reference. Use no more than 30 words) $charName:"
          },
        );
      }
    } else {
      if (vocabOverride != null && vocabOverride.isNotEmpty) {
        prevConversationPrompt.add(
          {
            'role': 'assistant',
            'content':
                "(My next dialog will use $charName's iconic language style, but with $vocabOverride. Use no more than 30 words) $charName:"
          },
        );
      } else {
        prevConversationPrompt.add(
          {
            'role': 'assistant',
            'content':
                "(My next dialog will use $charName's iconic language style. Use no more than 30 words) $charName:"
          },
        );
      }
    }
    final reqBody = jsonEncode(<String, dynamic>{
      'model': chatModelName,
      'messages': [
        {'role': 'user', 'content': userPrompt},
        {'role': 'assistant', 'content': assistantPrompt},
        ...prevConversationPrompt,
      ],
      'max_tokens': 300,
      'stop': ['\n$userName', '\n$charName'],
      'user': userId,
    });

    return openaiHttp(reqBody: reqBody, userId: userId);
  }

  static Future<String> openaiHttp({
    required String reqBody,
    required String userId,
  }) async {
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${Env.apiKey}',
        'Content-Type': 'application/json'
      },
      body: reqBody,
    );

    final resJson = jsonDecode(res.body);
    final tokensUsed = resJson['usage']['total_tokens'];
    UserModel.updateUserToken(id: userId, amt: tokensUsed);
    if (res.statusCode != 200) {
      print('${res.statusCode}');
    }
    return utf8.decode(res.bodyBytes);
  }

  static Future<String> characterGenerationV2({
    required String charName,
    required String charDesc,
    required String userId,
    int number = 15,
  }) async {
    final userPrompt1 = '''
Help me think of 10 iconic things that an actor/actress playing Donald Trump, the U.S. president may reference in a scene audition. Add END in a new line when you finish the list.''';
    final assistantPrompt1 = '''
Sure! Below are 10 iconic things that Donald Trump may reference in a dialog of a scene audition
-The wall 
-"Make America Great Again" slogan 
-Trump's catchphrase "You're Fired!" 
-The size of Trump's inauguration crowd 
-Trump's wealth and business success 
-China and trade deals 
-The fake news media 
-Hillary Clinton and her emails 
-North Korea and Kim Jong-Un 
-The coronavirus pandemic and Trump's response to it
END''';
    final userPrompt2 = '''
Amazing! Now do the same for $charName, $charDesc. I want $number iconic things this time.''';
    final assistantPrompt2 = '''
Absolutely! Below are $number iconic things that an actor/actress playing $charName may reference in a dialog of a scene audition
-$charName''';
    final reqBody = jsonEncode(<String, dynamic>{
      'model': chatModelName,
      'messages': [
        {'role': 'user', 'content': userPrompt1},
        {'role': 'assistant', 'content': assistantPrompt1},
        {'role': 'user', 'content': userPrompt2},
        {'role': 'assistant', 'content': assistantPrompt2},
      ],
      'max_tokens': 500,
      'stop': ['\nEND'],
      'temperature': 0,
    });
    return openaiHttp(reqBody: reqBody, userId: userId);
  }

  static Future<String> vocabGenerationV2({
    required String charName,
    required String charDesc,
    int number = 15,
  }) async {
    final prompts = [
      'Help me think of the one iconic phrase that remind people of Osama Bin Ladin.',
      'Sure! Death to America and its allies! Allahu Akbar!',
      'Do the same for Mario, from Super Mario Bros',
      "Sure! It's-a me, Mario! Let's-a go!",
      'Do the same for $charName, $charDesc',
      'Sure! '
    ];
    final reqBody = jsonEncode(<String, dynamic>{
      'model': chatModelName,
      'messages': [
        {'role': 'user', 'content': prompts[0]},
        {'role': 'assistant', 'content': prompts[1]},
        {'role': 'user', 'content': prompts[2]},
        {'role': 'assistant', 'content': prompts[3]},
        {'role': 'user', 'content': prompts[4]},
        {'role': 'assistant', 'content': prompts[5]},
      ],
      'max_tokens': 300,
      'temperature': 0,
      'stop': 'END'
    });
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${Env.apiKey}',
        'Content-Type': 'application/json'
      },
      body: reqBody,
    );
    print(prompts.join('\n'));
    return utf8.decode(res.bodyBytes);
  }

  static Future<String> chatCompletion(
      {required String charName,
      required String charDesc,
      required String vocab,
      required String userName,
      required String userDesc,
      required String reference,
      required List<dynamic> topics,
      required String prevConversation}) async {
    var instructions = '';
    final topicsStr = topics.join(', ');
    print('started $url');
    final userPrompt = '''
Simulate an online message chat between $userDesc called $userName, and $charName, $charDesc. $charName will ask about $topicsStr, in that order. In this conversation, $charName must $vocab
Once $charName gets all the answer to all of the questions, $charName will end the conversation. Add ENDOFCONV at the end when the conversation is finished.''';
    final assistantPrompt = '''
Sure! Below is a simulated online chat between $charName and $userName
$userName: Hello $charName
$prevConversation
$charName (referencing $reference):''';
    final reqBody = jsonEncode(<String, dynamic>{
      'model': chatModelName,
      'messages': [
        {'role': 'user', 'content': userPrompt},
        {'role': 'assistant', 'content': assistantPrompt},
      ],
      'stop': ['\n\n', '\n$userName'],
      'max_tokens': 300
    });

    print('$userPrompt\n$assistantPrompt');

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${Env.apiKey}',
        'Content-Type': 'application/json'
      },
      body: reqBody,
    );
    return res.body;
  }

  static Future<String> contentCompletion({
    required String contentType,
    required String facts,
    required String userName,
    required String starter,
  }) async {
    final userPrompt = '''
Using information from the FACTS below, generate $contentType for $userName.

FACTS:
$facts

Make sure to only include factual information from the provided facts above, do not add or assume new information!''';
    final assistantPrompt = '''
Sure! Based only on the facts you provided, below is the $contentType for $userName
$starter''';
    final reqBody = jsonEncode(<String, dynamic>{
      'model': chatModelName,
      'messages': [
        {
          'role': 'user',
          'content': userPrompt,
        },
        {'role': 'assistant', 'content': assistantPrompt},
      ],
      'stop': ['ENDOFCONTENT'],
      'max_tokens': 500
    });
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${Env.apiKey}',
        'Content-Type': 'application/json'
      },
      body: reqBody,
    );
    print('$userPrompt\n$assistantPrompt');
    return res.body;
  }

  static Future<String> contentExtraction({
    required String conversation,
    required List<dynamic> topics,
    required String userName,
  }) async {
    final topicStr = topics.join(', ');
    final userPrompt = '''
Using information from the imaginary conversation below, extract information about $topicStr. Add END at the end when you finish extracting information. Do not mention the conversation itself, as it is imaginary and it is only thre to get information about $userName
$conversation''';
    final assistantPrompt = '''
Sure! Below are the information extracted about $topicStr, in that order, without mentioning the conversation.''';
    final reqBody = jsonEncode(<String, dynamic>{
      'model': chatModelName,
      'messages': [
        {'role': 'user', 'content': userPrompt},
        {'role': 'assistant', 'content': assistantPrompt},
      ],
      'max_tokens': 500,
      'temperature': 0,
      'stop': 'END',
    });
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${Env.apiKey}',
        'Content-Type': 'application/json'
      },
      body: reqBody,
    );
    print('$userPrompt\n$assistantPrompt');
    return res.body;
  }

  static Future<String> characterGeneration({
    required String charName,
    required String charDesc,
    int number = 15,
  }) async {
    final userPrompt1 = '''
Help me think of 10 iconic things that Donald Trump, the U.S. president may reference in a dialog. Add END at the end when you finish the list.''';
    final assistantPrompt1 = '''
Sure! Below are 10 iconic things that Donald Trump may reference in a dialog
-The wall 
-"Make America Great Again" slogan 
-Trump's catchphrase "You're Fired!" 
-The size of Trump's inauguration crowd 
-Trump wealth and business success 
-China and trade deals 
-The fake news media 
-Hillary Clinton and her emails 
-North Korea and Kim Jong-Un 
-The coronavirus pandemic and Trump's response to itEND''';
    final userPrompt2 = '''
Amazing! Now do the same for $charName, $charDesc. I want $number iconic things this time.''';
    final assistantPrompt2 = '''
Absolutely! Below are $number iconic things that $charName may reference in a dialog
-''';
    final reqBody = jsonEncode(<String, dynamic>{
      'model': chatModelName,
      'messages': [
        {'role': 'user', 'content': userPrompt1},
        {'role': 'assistant', 'content': assistantPrompt1},
        {'role': 'user', 'content': userPrompt2},
        {'role': 'assistant', 'content': assistantPrompt2},
      ],
      'max_tokens': 500,
      'stop': 'END',
      'temperature': 0,
    });
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${Env.apiKey}',
        'Content-Type': 'application/json'
      },
      body: reqBody,
    );
    print('$userPrompt1\n$assistantPrompt1\n$userPrompt2\n$assistantPrompt2');
    return res.body;
  }

  static Future<String> vocabGeneration({
    required String charName,
    required String charDesc,
    required String userId,
    int number = 15,
  }) async {
    final prompts = [
      'Help me describe the attitude and language style for an online chatbot that mimicks Snake, from metal gear solid, in 50 words or less',
      'Sure! Snake bot would always have a serious and no-nonsense attitude, and his language style would be concise and precise, with a tendency to speak in military jargon.',
      'Do the same for Tyler1, the league streamer',
      'Sure! Tyler1 bot would always have an aggressive attitude, and his language style would be filled with internet slangs, with frequent use of explicit language.',
      'Do the same for Nagisa, from Clannad',
      'Sure! Nagisa bot would always have a gentle and compassionate attitude, and her language style would be soft-spoken and polite, with well structured sentences.',
      'Do the same for Shakespear, the famous writer',
      'Sure! Shakespeare bot would always have an eloquent and sophisticated attitude, and his language style would be characterized by iambic pentameter, rich vocabulary, and an extensive use of literary devices, such as metaphors, similes, and allusions.',
      'Do the same for $charName, $charDesc',
      'Sure! $charName bot would always have '
    ];
    final reqBody = jsonEncode(<String, dynamic>{
      'model': chatModelName,
      'messages': [
        {'role': 'user', 'content': prompts[0]},
        {'role': 'assistant', 'content': prompts[1]},
        {'role': 'user', 'content': prompts[2]},
        {'role': 'assistant', 'content': prompts[3]},
        {'role': 'user', 'content': prompts[4]},
        {'role': 'assistant', 'content': prompts[5]},
        {'role': 'user', 'content': prompts[6]},
        {'role': 'assistant', 'content': prompts[7]},
        {'role': 'user', 'content': prompts[8]},
        {'role': 'assistant', 'content': prompts[9]},
      ],
      'max_tokens': 300,
      'temperature': 0,
      'stop': 'END'
    });
    return openaiHttp(reqBody: reqBody, userId: userId);
  }
}
