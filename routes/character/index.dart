import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/open_ai_api.dart';

/* 
  Get /character
  Body: String 'CharName||CharDesc'
  Auth: token required in header
*/
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final body = await request.body();
  final bodyContent = body.split('||');
  final character =
      await OpenAIAPI.characterCompletion(bodyContent[0], bodyContent[1]);
  return Response.json(body: {
    'name': character.name,
    'desc': character.desc,
    'vocab': character.vocab,
    'characterstics': character.characteristics,
  },);
}
