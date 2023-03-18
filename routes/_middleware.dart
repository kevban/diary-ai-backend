import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:diary_ai_backend/env/env.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';


Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(fromShelfMiddleware(corsHeaders()))
      .use(provider<String>((context) {
        final authHeader = context.request.headers['authorization'];
        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          final token = authHeader.substring(7);
          print(token);
          final jwt = JWT.tryVerify(token, SecretKey(Env.jwtSecret));
          if (jwt != null) {
            return jwt.payload['id'] as String;
          }
        }
        return '';
      }),);
}
