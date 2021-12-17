import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/usersticker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'db.db'),
      onCreate: (database, version) async {
        await database.execute(
            "CREATE TABLE stickers(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, desc TEXT NOT NULL, rarity INTEGER NOT NULL, collection INTEGER NOT NULL, key BLOB NOT NULL)");
        await database.execute(
            "CREATE TABLE collections(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, version INTEGER NOT NULL)");
        await database.execute("CREATE TABLE userstickers(id INTEGER PRIMARY KEY AUTOINCREMENT, quantity INTEGER)");
      },
      version: 1,
    );
  }

  Future<int> insertUserStickers(List<UserSticker> userstickers) async {
    int result = 0;
    Database db = await initializeDB();
    await db.execute("DROP TABLE IF EXISTS userstickers");
    await db.execute("CREATE TABLE userstickers(id INTEGER PRIMARY KEY AUTOINCREMENT, quantity INTEGER)");
    for (var usersticker in userstickers) {
      //print(usersticker);
      result = await db.insert('userstickers', usersticker.toMap());
    }
    return result;
  }

  Future<int> insertSticker(List<Sticker> stickers) async {
    int result = 0;
    Database db = await initializeDB();
    for (var sticker in stickers) {
      result = await db.insert('stickers', sticker.toMap());
    }
    return result;
  }

  Future<int> insertCollection(List<Collection> collections) async {
    int result = 0;
    Database db = await initializeDB();
    for (var collection in collections) {
      result = await db.insert('collections', collection.toMap());
    }
    return result;
  }

  Future<List<UserSticker>> retrieveUserStickers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('userstickers');
    return queryResult.map((e) => UserSticker.fromJson(e)).toList();
  }

  Future<List<Sticker>> retrieveSticker({required int id}) async {
    final Database db = await initializeDB();
    List<Map<String, Object?>> queryResult;
    queryResult = await db.query('stickers', where: 'id=$id');
    List<Sticker> mapped = queryResult.map((e) => Sticker.fromJson(e)).toList();
    return mapped;
  }

  Future<List<Sticker>> retrieveStickers({int? id}) async {
    final Database db = await initializeDB();
    List<int> stickerids = [];
    List<int> stickerquantities = [];
    List<UserSticker> userstickersid = await retrieveUserStickers();
    for (var element in userstickersid) {
      stickerids.add(element.id);
      stickerquantities.add(element.quantity!);
    }
    List<Map<String, Object?>> queryResult;
    if (id != null) {
      queryResult = await db.query('stickers', where: 'collection=$id');
    } else {
      queryResult = await db.query('stickers');
    }
    List<Sticker> mapped = queryResult.map((e) => Sticker.fromJson(e)).toList();
    for (Sticker sticker in mapped) {
      if (stickerids.contains(sticker.id)) {
        sticker.quantity = stickerquantities[stickerids.indexOf(sticker.id)];
      } else {
        sticker.lockedSticker();
      }
    }
    //mapped.removeWhere((e) => toRemove.contains(e));
    return mapped;
  }

  Future<List<Collection>> retrieveCollections() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('collections');
    return queryResult.map((e) => Collection.fromJson(e)).toList();
  }
}
