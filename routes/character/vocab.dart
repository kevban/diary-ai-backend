import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/chatgpt_api.dart';
import 'package:diary_ai_backend/classes/character.dart';
import 'package:diary_ai_backend/db/character_model.dart';
import 'package:diary_ai_backend/db/user_model.dart';

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
      final user = await UserModel.getUserById(id: context.read<String>());
      if (user == null) {
        return Response.json(statusCode: 401, body: {'error': 'unauthorized'});
      } else if (user['curToken'] as int > 10000) {
        if ((user['lastUsed'] as DateTime)
            .add(const Duration(days: 1))
            .isBefore(DateTime.now())) {
          await UserModel.refreshTokens(id: context.read<String>());
        } else {
          // return Response.json(
          //     statusCode: 401, body: {'error': 'out of tokens'});
        }
      }
      final body = await request.json();
      final vocab = await ChatGPTAPI.vocabGeneration(
        userId: context.read<String>(),
        charName: body['charName'] as String,
        charDesc: body['charDesc'] as String,
      );
      return Response.json(
        statusCode: 201,
        body: vocab,
      );
    case 'GET':
      return Response.json(body: 'hi');
    default:
      return Response.json(statusCode: 404, body: {'error': 'not found'});
  }
}
