import 'dart:convert';

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
      }
      final body = await request.json();
      await CharacterModel.addChar(
        id: body['id'] as String,
        name: body['name'] as String,
        desc: body['desc'] as String,
        vocab: body['vocab'] as String,
        characteristics: (body['characteristics'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        imgBase64: body['imgBase64'] as String?,
      );
      return Response.json(
        statusCode: 201,
        body: {'message': 'success'},
      );
    case 'GET':
      final body = request.uri.queryParameters;
      if (body['charName'] != null) {
        final characters = await CharacterModel.getChar(
          searchTerm: body['charName']!,
        );
        return Response.json(
          body: characters,
        );
      } else {
        final characters = await CharacterModel.getPopularChar();
        return Response.json(body: characters);
      }
    default:
      return Response.json(statusCode: 404, body: {'error': 'not found'});
  }
}
