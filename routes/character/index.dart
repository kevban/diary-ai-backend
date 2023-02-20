import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/open_ai_api.dart';

/* 
  POST /character
  Body: {
    name: String,
    desc: String
  }
  Auth: token required in header
  Response: {
    name,
    desc,
    vocab,
    characteristics
  }
*/
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  switch (request.method.value) {
    case 'POST':
      final body = await request.formData();
      final character = await OpenAIAPI.characterCompletion(
          body['name']!, body['desc']!,);
      return Response.json(
        body: {
          'name': character.name,
          'desc': character.desc,
          'vocab': character.vocab,
          'characteristics': character.characteristics,
        },
      );
    default:
      return Response.json(statusCode: 404, body: {'message': 'not found'});
  }
}
