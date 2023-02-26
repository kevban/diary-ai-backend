import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/open_ai_api.dart';
import 'package:diary_ai_backend/classes/character.dart';
import 'package:diary_ai_backend/db/character_model.dart';

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
    characteristics
  }
*/
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  switch (request.method.value) {
    case 'POST':
      final body = await request.formData();
      final character = await OpenAIAPI.characterCompletion(
        body['name']!,
        body['desc']!,
      );
      character.imgBase64 = body['imgBase64'];
      await CharacterModel.addChar(character);
      return Response.json(
        body: {
          'name': character.name,
          'desc': character.desc,
          'vocab': character.vocab,
          'imgBase64': character.imgBase64,
          'characteristics': character.characteristics,
        },
      );
    case 'GET':
      final charList = await CharacterModel.getChar();
      return Response.json(body: {'characters': charList});
    default:
      return Response.json(statusCode: 404, body: {'message': 'not found'});
  }
}
