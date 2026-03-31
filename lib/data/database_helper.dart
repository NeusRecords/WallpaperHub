import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/wallpaper_model.dart';

class DatabaseHelper {
  static const _databaseName = "Wallpapers.db";
  static const _databaseVersion = 1;

  static const table = 'favorites';

  static const columnId = 'id';
  static const columnPhotographer = 'photographer';
  static const columnPhotographerUrl = 'photographer_url';
  static const columnPhotographerId = 'photographer_id';
  static const columnPortrait = 'portrait';
  static const columnOriginal = 'original';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    if (kIsWeb) return null;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnPhotographer TEXT NOT NULL,
            $columnPhotographerUrl TEXT NOT NULL,
            $columnPhotographerId INTEGER NOT NULL,
            $columnPortrait TEXT NOT NULL,
            $columnOriginal TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(WallpaperModel wallpaper) async {
    if (kIsWeb) return 0;
    Database? db = await instance.database;
    if (db == null) return 0;
    return await db.insert(table, {
      columnId: wallpaper.photographerId, 
      columnPhotographer: wallpaper.photographer,
      columnPhotographerUrl: wallpaper.photographerUrl,
      columnPhotographerId: wallpaper.photographerId,
      columnPortrait: wallpaper.src.portrait,
      columnOriginal: wallpaper.src.original,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WallpaperModel>> queryAllRows() async {
    if (kIsWeb) return [];
    Database? db = await instance.database;
    if (db == null) return [];
    var res = await db.query(table);
    List<WallpaperModel> list = res.isNotEmpty
        ? res.map((c) => WallpaperModel.fromMap({
              "photographer": c[columnPhotographer],
              "photographer_id": c[columnPhotographerId],
              "photographer_url": c[columnPhotographerUrl],
              "src": {
                "portrait": c[columnPortrait],
                "original": c[columnOriginal],
                "small": c[columnPortrait] // Fallback
              }
            })).toList()
        : [];
    return list;
  }

  Future<int> delete(int id) async {
    if (kIsWeb) return 0;
    Database? db = await instance.database;
    if (db == null) return 0;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(int id) async {
    if (kIsWeb) return false;
    Database? db = await instance.database;
    if (db == null) return false;
    var res = await db.query(table, where: '$columnId = ?', whereArgs: [id]);
    return res.isNotEmpty;
  }
}
