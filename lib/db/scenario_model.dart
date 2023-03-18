import 'package:diary_ai_backend/db/db.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// db model for Character
class ScenarioModel {
  /// add a character to database
  static Future<dynamic> addScenario({
    required String title,
    required String desc,
    required String setting,
    required String? instruction,
    required double referenceStrength,
    required bool userStart,
    required String id,
    required String? imgBase64,
  }) async {
    final db = await connectDb();
    await db.collection('scenarios').insertOne({
      'title': title,
      'description': desc,
      'setting': setting,
      'instruction': instruction,
      'imgBase64': imgBase64,
      'userStart': userStart,
      'referenceStrength': referenceStrength,
      'id': id,
      'liked': 0,
      'reported': 0,
      'downloads': 0,
    });
  }

  static Future<List<Map<String, dynamic>>> getScenario({
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
        .collection('scenarios')
        .find(
          where
              .match('title', searchTerm, caseInsensitive: true)
              .sortBy('downloads', descending: true)
              .limit(limit),
        )
        .toList();
    return result;
  }

  static Future<List<Map<String, dynamic>>> getPopularScenarios({
    int limit = 25,
  }) async {
    final db = await connectDb();
    final result = await db
        .collection('scenarios')
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
        .collection('scenarios')
        .updateOne(where.eq('id', id), modify.inc('downloads', 1));
    return null;
  }
}
