import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:diary_ai_backend/db/db.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../env/env.dart';

/// db model for User
class UserModel {
  static Future<Map<String, dynamic>?> getUserById({required String id}) async {
    final db = await connectDb();
    Map<String, dynamic>? user =
        await db.collection('users').findOne(where.eq('id', id));
    return user;
  }

  static Future<void> updateUserToken(
      {required String id, required amt}) async {
    final db = await connectDb();
    final res = await db.collection('users').updateOne(
          where.eq('id', id),
          modify.inc('curToken', amt).inc('cumToken', amt),
        );
  }

  static Future<void> refreshTokens({required String id}) async {
    final db = await connectDb();
    await db.collection('users').updateOne(
          where.eq('id', id),
          modify.set('curToken', 0).set('lastUsed', DateTime.now()),
        );
  }

  static Future<Map<String, dynamic>> addUser(
      {required String? deviceId, required String ipAddress}) async {
    final db = await connectDb();
    String? userUID = deviceId == null ? null : deviceId + ipAddress;
    String id = Uuid().v4();
    final jwt = JWT(
      {
        'id': id,
      },
    );
    String token = jwt.sign(SecretKey(Env.jwtSecret));
    if (userUID == null) {
      await db.collection('users').insertOne({
        'id': id,
        'curToken': 0,
        'cumToken': 0,
        'type': 'free',
        'lastUsed': DateTime.now()
      });
      return {'token': token, 'curToken': 0};
    } else {
      final user =
          await db.collection('users').findOne(where.eq('userUID', userUID));
      if (user != null) {
        final jwt = JWT(
          {
            'id': user['id'],
          },
        );
        String token = jwt.sign(SecretKey(Env.jwtSecret));
        return {'token' : token, 'curToken' : user['curToken']};
      } else {
        await db.collection('users').insertOne({
          'userUID': userUID,
          'id': id,
          'curToken': 0,
          'cumToken': 0,
          'type': 'free',
          'lastUsed': DateTime.now(),
        });
        return {'token': token, 'curToken': 0};
      }
    }
  }
}
