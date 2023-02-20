import 'package:mongo_dart/mongo_dart.dart';

/// db is the reference to mongodb database
Db db = Db('mongodb+srv://papaya2:<Xx7XIvd7N6Llr4CN>@cluster1.loqm7pi.mongodb.net/?retryWrites=true&w=majority');

/// returns the db instance. Connect to db if not connected already
Future<Db> connectDb() async {
  if (!db.isConnected) {
    await db.open();
  }
  return db;
}
