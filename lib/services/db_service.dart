import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/stock_record.dart';
import '../models/cup_preset.dart';

class DBService {
  static final DBService instance = DBService._init();
  static Database? _database;

  DBService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stock_tracking_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Cup Presets Table
    await db.execute('''
      CREATE TABLE cup_presets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ounces REAL NOT NULL,
        milliliters REAL NOT NULL,
        name_ar TEXT NOT NULL,
        name_en TEXT NOT NULL,
        is_custom INTEGER NOT NULL,
        low_stock_threshold REAL NOT NULL
      )
    ''');

    // 2. Stock Records Table
    await db.execute('''
      CREATE TABLE stock_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        items_json TEXT NOT NULL,
        total_yesterday_stock REAL NOT NULL,
        total_operating_units REAL NOT NULL,
        total_current_stock REAL NOT NULL,
        total_actual_consumption REAL NOT NULL,
        total_variance REAL NOT NULL,
        notes TEXT
      )
    ''');

    // Pre-populate built-in default dual-unit presets
    for (var preset in CupPreset.defaultPresets) {
      await db.insert('cup_presets', preset.toMap());
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS stock_records');
      await db.execute('DROP TABLE IF EXISTS cup_presets');
      await _createDB(db, newVersion);
    }
  }

  // --- CUP PRESETS CRUD ---
  Future<int> insertCupPreset(CupPreset preset) async {
    final db = await instance.database;
    return await db.insert('cup_presets', preset.toMap());
  }

  Future<List<CupPreset>> getAllCupPresets() async {
    final db = await instance.database;
    final result = await db.query('cup_presets', orderBy: 'ounces ASC');
    if (result.isEmpty) {
      // Re-populate default presets if empty
      for (var preset in CupPreset.defaultPresets) {
        await db.insert('cup_presets', preset.toMap());
      }
      final fresh = await db.query('cup_presets', orderBy: 'ounces ASC');
      return fresh.map((json) => CupPreset.fromMap(json)).toList();
    }
    return result.map((json) => CupPreset.fromMap(json)).toList();
  }

  Future<int> deleteCupPreset(int id) async {
    final db = await instance.database;
    return await db.delete('cup_presets', where: 'id = ?', whereArgs: [id]);
  }

  // --- STOCK RECORDS CRUD ---
  Future<int> insertRecord(StockRecord record) async {
    final db = await instance.database;
    return await db.insert('stock_records', record.toMap());
  }

  Future<List<StockRecord>> getAllRecords() async {
    final db = await instance.database;
    final result = await db.query('stock_records', orderBy: 'id DESC');
    return result.map((json) => StockRecord.fromMap(json)).toList();
  }

  Future<int> deleteRecord(int id) async {
    final db = await instance.database;
    return await db.delete('stock_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- OFFLINE BACKUP & RESTORE ---
  Future<String?> backupDatabaseToJSON() async {
    try {
      final presets = await getAllCupPresets();
      final records = await getAllRecords();

      final backupData = {
        'version': 2,
        'timestamp': DateTime.now().toIso8601String(),
        'presets': presets.map((p) => p.toMap()).toList(),
        'records': records.map((r) => r.toMap()).toList(),
      };

      final String jsonStr = json.encode(backupData);
      final Directory? dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      if (dir == null) return null;

      final String backupPath = "${dir.path}/Taqfeel_Backup_${DateTime.now().millisecondsSinceEpoch}.json";
      final File backupFile = File(backupPath);
      await backupFile.writeAsString(jsonStr);

      return backupPath;
    } catch (e) {
      print("Backup Exception: $e");
      return null;
    }
  }

  Future<bool> restoreDatabaseFromJSON(String jsonStr) async {
    try {
      final Map<String, dynamic> backupData = json.decode(jsonStr);
      final db = await instance.database;

      await db.transaction((txn) async {
        await txn.delete('cup_presets');
        await txn.delete('stock_records');

        if (backupData['presets'] != null) {
          for (var pMap in backupData['presets'] as List) {
            await txn.insert('cup_presets', pMap as Map<String, dynamic>);
          }
        }
        if (backupData['records'] != null) {
          for (var rMap in backupData['records'] as List) {
            await txn.insert('stock_records', rMap as Map<String, dynamic>);
          }
        }
      });
      return true;
    } catch (e) {
      print("Restore Exception: $e");
      return false;
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
