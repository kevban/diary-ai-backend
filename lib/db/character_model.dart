import 'package:diary_ai_backend/classes/character.dart';
import 'package:diary_ai_backend/db/db.dart';

/// db model for Character
class CharacterModel {
  /// add a character to database
  static Future<dynamic> addChar(Character character) async {
    final db = await connectDb();
    await db.collection('characters').insertOne({
      'name': character.name,
      'desc': character.desc,
      'vocab': character.vocab,
      'characteristics': character.characteristics
    });
  }

  /// Get all characters
  static Future<List<dynamic>> getChar() async {
    final db = await connectDb();
    final characters = await db
        .collection('characters')
        .find()
        .toList();
    return characters;
  }
}
