import 'package:mongo_dart/mongo_dart.dart';

/// the reference to mongodb database
Db? db;
/// returns the db instance. Connect to db if not connected already
Future<Db> connectDb() async {
  db = await Db.create('mongodb+srv://papaya2:Xx7XIvd7N6Llr4CN@cluster1.loqm7pi.mongodb.net/diary-ai?retryWrites=true&w=majority');
  if (!db!.isConnected) {
    await db!.open();
  }
  return db!;
}
