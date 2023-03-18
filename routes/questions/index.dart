import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/chatgpt_api.dart';
import 'package:diary_ai_backend/classes/character.dart';
import 'package:diary_ai_backend/db/user_model.dart';

/* 
  POST /question
  Body: {
    charName: String,
    charDesc: String,
    vocab: String,
    userName: String,
    userDesc: String,
    reference: String,
    topic: String,
    prevConversation: String?
    sequence: String,
  }
  Auth: token required in header

  Example:


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
      List<String> prevConversationArr =
          (body['prevConversation'] as String).split('\n');
      final res = await ChatGPTAPI.chatCompletionV2(
        userId: context.read<String>(),
        userStart: body['userStart'] as bool,
        charName: body['charName'] as String,
        charDesc: body['charDesc'] as String,
        vocab: body['vocab'] as String,
        userName: body['userName'] as String,
        userDesc: body['userDesc'] as String,
        reference: body['reference'] as String?,
        prevConversation: prevConversationArr,
        settings: body['settings'] as String,
        vocabOverride: body['vocabOverride'] as String?,
      );
      return Response.json(
        statusCode: 201,
        body: res,
      );
    default:
      return Response.json(statusCode: 404, body: 'not found');
  }
}
