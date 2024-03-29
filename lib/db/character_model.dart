import 'package:diary_ai_backend/db/db.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// db model for Character
class CharacterModel {
  /// add a character to database
  static Future<dynamic> addChar({
    required String name,
    required String desc,
    required String vocab,
    required List<String> characteristics,
    required String? imgBase64,
    required String id,
  }) async {
    final db = await connectDb();
    await db.collection('characters').insertOne({
      'name': name,
      'desc': desc,
      'vocab': vocab,
      'characteristics': characteristics,
      'imgBase64': imgBase64,
      'id': id,
      'liked': 0,
      'reported': 0,
      'downloads': 0,
    });
  }

  static Future<List<Map<String, dynamic>>> getChar({
    required String searchTerm,
    int limit = 25,
  }) async {
    final db = await connectDb();
    Map<String, dynamic> query = {
      'name': {
        r'$regex': RegExp(searchTerm, caseSensitive: false),
        r'$options': 'i',
      },
    };
    final result = await db
        .collection('characters')
        .find(
          where
              .match('name', searchTerm, caseInsensitive: true)
              .sortBy('downloads', descending: true)
              .limit(limit),
        )
        .toList();
    return result;
  }

  static Future<List<Map<String, dynamic>>> getPopularChar({
    int limit = 25,
  }) async {
    final db = await connectDb();
    final result = await db
        .collection('characters')
        .find(where
            .sortBy('downloads')
            .limit(limit)
            .sortBy('downloads', descending: true),)
        .toList();
    return result;
  }

  static Future<dynamic> addDownloads({required String id}) async {
    final db = await connectDb();
    final result = await db
        .collection('characters')
        .updateOne(where.eq('id', id), modify.inc('downloads', 1));
    return null;
  }
}
