import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/chatgpt_api.dart';
import 'package:diary_ai_backend/classes/character.dart';
import 'package:diary_ai_backend/db/character_model.dart';
import 'package:diary_ai_backend/db/scenario_model.dart';
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
      var body = await request.json();
      if (body['referenceStrength'] is int) {
        body['referenceStrength'] = (body['referenceStrength'] as int).toDouble();
      }
      await ScenarioModel.addScenario(
        title: body['title'] as String,
        desc: body['description'] as String,
        setting: body['setting'] as String,
        instruction: body['instruction'] as String?,
        referenceStrength: body['referenceStrength'] as double,
        userStart: body['userStart'] as bool,
        id: body['id'] as String,
        imgBase64: body['imgBase64'] as String?,
      );
      return Response.json(
        statusCode: 201,
        body: {'message': 'success'},
      );
    case 'GET':
      final body = request.uri.queryParameters;
      if (body['scenarioTitle'] != null) {
        final scenarios = await ScenarioModel.getScenario(
          searchTerm: body['scenarioTitle']!,
        );
        return Response.json(
          body: scenarios,
        );
      } else {
        final scenarios = await ScenarioModel.getPopularScenarios();
        return Response.json(body: scenarios);
      }
    default:
      return Response.json(statusCode: 404, body: {'error': 'not found'});
  }
}
