import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:diary_ai_backend/db/user_model.dart';
import 'package:diary_ai_backend/env/env.dart';

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
  final requestAddress = request.connectionInfo.remoteAddress.address;
  switch (request.method.value) {
    case 'GET':
      final body = await request.json();
      final jwt = JWT.tryVerify(
        body['token'] as String,
        SecretKey(Env.jwtSecret),
      );
      if (jwt != null) {
        final user =
            await UserModel.getUserById(id: jwt.payload['id'] as String);
        return Response.json(body: jsonEncode({'user': user}));
      } else {
        return Response.json(statusCode: 401, body: {'error': 'unauthorized'});
      }

    case 'POST':
      final body = await request.json();
      final res = await UserModel.addUser(
          deviceId: body['deviceId'] as String?, ipAddress: requestAddress);
      return Response.json(
        statusCode: 201,
        body: jsonEncode({'token': res['token'], 'curToken': res['curToken']}),
      );
    default:
      return Response.json(statusCode: 404, body: {'error': 'not found'});
  }
}
