import 'package:diary_ai_backend/classes/character.dart';
import 'package:diary_ai_backend/db/db.dart';


/// db model for Character
class CharacterModel {

  /// add a character to database
  static Future<dynamic> addChar(Character character) async {
    final db = await connectDb();
    await db.collection('characters').insertOne({'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'});
  }
}
