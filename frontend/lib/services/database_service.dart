import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/riwayat_proyek.dart';

/// Service untuk menyimpan dan mengambil riwayat proyek perhitungan PLTS
/// secara lokal menggunakan sqflite (SQLite di device).
///
/// Karena aplikasi ini dipakai sebagai tool personal (bukan multi-user
/// dengan data terpusat), semua riwayat cukup disimpan di database lokal
/// per device, tanpa perlu backend server.
///
/// Catatan platform: sqflite native hanya jalan di Android/iOS. Untuk
/// memudahkan development/testing di Windows/Linux/macOS desktop,
/// databaseFactory diarahkan ke sqflite_common_ffi. Web tidak didukung
/// sama sekali oleh sqflite (baik native maupun ffi), jadi fitur riwayat
/// hanya bisa dites di Android/iOS/desktop, tidak di Chrome.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;
  static bool _ffiInitialized = false;

  static const String _tableName = 'riwayat_proyek';

  void _pastikanFfiSiap() {
    if (_ffiInitialized) return;
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _ffiInitialized = true;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _pastikanFfiSiap();
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'solacalcsre.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            nama_proyek TEXT NOT NULL,
            beban_json TEXT NOT NULL,
            parameter_json TEXT NOT NULL,
            total_daya_watt REAL NOT NULL,
            total_watt_hours REAL NOT NULL,
            jumlah_aki_vrla INTEGER NOT NULL,
            jumlah_panel_vrla INTEGER NOT NULL,
            jumlah_aki_lifepo4 INTEGER NOT NULL,
            jumlah_panel_lifepo4 INTEGER NOT NULL,
            dibuat_pada TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Menyimpan proyek baru
  Future<void> simpanProyek(RiwayatProyek proyek) async {
    final db = await database;
    await db.insert(
      _tableName,
      proyek.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mengambil semua riwayat proyek, diurutkan dari yang terbaru
  Future<List<RiwayatProyek>> ambilSemuaProyek() async {
    final db = await database;
    final result = await db.query(_tableName, orderBy: 'dibuat_pada DESC');
    return result.map((row) => RiwayatProyek.fromDbMap(row)).toList();
  }

  /// Mengambil satu proyek berdasarkan id
  Future<RiwayatProyek?> ambilProyekById(String id) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return RiwayatProyek.fromDbMap(result.first);
  }

  /// Menghapus satu proyek
  Future<void> hapusProyek(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Menghapus seluruh riwayat (dipakai untuk fitur "reset data" opsional)
  Future<void> hapusSemuaProyek() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
