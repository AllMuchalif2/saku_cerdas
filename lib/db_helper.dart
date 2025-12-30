import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // INIT DATABASE

  static Future<Database> db() async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'saku_cerdas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  // CREATE TABLES
  static Future<void> _createTables(Database db, int version) async {
    // KATEGORI
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kategori (
        kategori_id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        tipe TEXT CHECK(tipe IN ('PEMASUKAN','PENGELUARAN')),
      );
    ''');

    // TABUNGAN
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tabungan (
        tabungan_id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        target_jumlah REAL NOT NULL,
        jumlah REAL DEFAULT 0,
        tenggat_waktu TEXT
      );
    ''');

    // SALDO
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saldo (
        saldo_id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        total INTEGER DEFAULT 0,
        );
    ''');

    //  TRANSAKSI
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transaksi (
        transaksi_id INTEGER PRIMARY KEY AUTOINCREMENT,
        saldo_id INTEGER NOT_NULL,
        kategori_id INTEGER NOT_NULL,
        tabungan_id INTEGER ,
        jumlah REAL NOT NULL,
        tanggal TEXT DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (saldo_id)
          REFERENCES saldo (saldo_id)
          ON UPDATE NO ACTION
          ON DELETE NO ACTION,
        FOREIGN KEY (kategori_id)
          REFERENCES kategori (kategori_id)
          ON UPDATE NO ACTION
          ON DELETE NO ACTION,
        FOREIGN KEY (tabungan_id)
          REFERENCES tabungan (tabungan_id)
          ON UPDATE NO ACTION
          ON DELETE NO ACTION
      );
    ''');
  }
}
