import 'package:mongo_dart/mongo_dart.dart';

import 'constant_sup.dart'; // Ensure this file contains MONGO_URL and COLLECTION_NAME

class MongoDatabase {
  static Db? db;
  static DbCollection? collection;

  static Future<void> connect() async {
    if (db == null) {
      db = await Db.create(MONGO_URL);
      await db!.open();
      collection = db!.collection(COLLECTION_NAME);
    } else if (!db!.isConnected) {
      await db!.open();
    }
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    await connect(); // Ensure we are connected
    return await collection!.find().toList();
  }

  static Future<void> deleteUser(String userId) async {
    await connect(); // Ensure the database connection is open
    await collection!.remove(where.eq(
        'userId', userId)); // Adjust 'userId' with your unique identifier field
  }
}
