import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/castle_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  final List<Map<String, dynamic>> _webCastles = [];
  final List<Map<String, dynamic>> _webCheckIns = [];
// 💡 請在類別內部最上方（約第 11 行附近）加上這行變數
  bool isChugokuBadgeClaimed = false; // 記錄中國地區徽章是否已領取

  Future<dynamic> get database async {
    if (kIsWeb) {
      if (_webCastles.isEmpty) {
        // 擴充 Web 預載資料
        _getInitialCastles().forEach((c) => _webCastles.add(c.toMap()));
      }
      return null;
    }
    return _database ??= await _initDB('castles.db');
  }

  List<CastleModel> _getInitialCastles() {
    return [
      CastleModel(id: '070', nameKey: 'castle_okayama', latitude: 34.6652, longitude: 133.9362, area: 'Chugoku'),
      CastleModel(id: '071', nameKey: 'castle_tottori', latitude: 35.5042, longitude: 134.2403, area: 'Chugoku'),
      CastleModel(id: '072', nameKey: 'castle_matsue', latitude: 35.4752, longitude: 133.0506, area: 'Chugoku'),
      CastleModel(id: '073', nameKey: 'castle_yonago', latitude: 35.4247, longitude: 133.3261, area: 'Chugoku'),
      CastleModel(id: '074', nameKey: 'castle_bitchu_matsuyama', latitude: 34.8089, longitude: 133.6222, area: 'Chugoku'),
    ];
  }

Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  return await openDatabase(
    join(dbPath, filePath), 
    version: 2, // <-- 強制升級版本號，破壞舊快取
    onCreate: _createDB,
    onUpgrade: (db, oldVersion, newVersion) async {
      // 如果版本更新，直接清空舊表重新觸發建立
      await db.execute('DROP TABLE IF EXISTS castles');
      await db.execute('DROP TABLE IF EXISTS check_ins');
      await _createDB(db, newVersion);
    },
  );
}

  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE castles(id TEXT PRIMARY KEY, nameKey TEXT, latitude REAL, longitude REAL, area TEXT)');
    await db.execute('CREATE TABLE check_ins(castleId TEXT PRIMARY KEY, checkInTime TEXT, photoPath TEXT)');
    
    await db.transaction((txn) async {
      for (var castle in _getInitialCastles()) {
        await txn.insert('castles', castle.toMap());
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchCastles() async {
    if (kIsWeb) return _webCastles;
    return await (await database as Database).query('castles');
  }

  Future<int> insertCheckIn(Map<String, dynamic> checkIn) async {
    if (kIsWeb) {
      _webCheckIns.removeWhere((c) => c['castleId'] == checkIn['castleId']);
      _webCheckIns.add(checkIn);
      return 1;
    }
    return await (await database as Database).insert('check_ins', checkIn, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> fetchCheckIns() async {
    if (kIsWeb) return _webCheckIns;
    return await (await database as Database).query('check_ins');
  }
}
