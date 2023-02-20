import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/open_ai_api.dart';
import 'package:diary_ai_backend/classes/character.dart';

/* 
  POST /question
  Body: {
    name: String,
    desc: String,
    vocab: String,
    characteristics: String,
    sequence: String,
    topic: String,
    userName: String,
    userResponse: String?,
    prevQuestion: String?
  }
  Auth: token required in header

  Example:
  {
    "name": "Nagisa",
    "desc": "Anime character from Clannad",
    "vocab": "Casual, poetic language",
    "characteristics": "Is the daughter of Akio and Sanae Furukawa, who run the local bakery"
    "sequence": 'end',
    "topic": "User's mood",
    "userName": "Kevin",
    "userResponse": "That is all, thank you.",
    "prevQuestion": "It's admirable that you are able to keep going, Kevin. There is no end to the tasks and errands one must attend to when putting their heart into something. Is there anything else you need to take care of today before heading back to the Furukawa Bakery?"
}

*/

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  switch (request.method.value) {
    case 'POST':
      final body = await request.formData();
      final res = await OpenAIAPI.responseCompletion(
        body['name']!,
        body['desc']!,
        body['vocab']!,
        body['characteristic']!,
        body['sequence']!,
        body['topic']!,
        body['userName']!,
        (body['prevConversation'] == null) ? null : body['prevConversation'],
      );
      print(res[0]);
      print(res[1]);
      return Response.json(
        body: {'response': res[0], 'prompts': res[1]},
      );
    default:
      return Response.json(statusCode: 404, body: {'message': 'not found'});
  }
}
