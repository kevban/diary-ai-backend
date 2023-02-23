import 'package:diary_ai_backend/env/env.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// the reference to mongodb database
Db? db;
/// returns the db instance. Connect to db if not connected already
Future<Db> connectDb() async {
  db = await Db.create(Env.mongodbUri);
  if (!db!.isConnected) {
    await db!.open();
  }
  return db!;
}
