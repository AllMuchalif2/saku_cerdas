import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // Inisialisasi Database
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
      // Mengaktifkan dukungan foreign key
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Membuat Tabel-Tabel
  static Future<void> _createTables(Database db, int version) async {
    // 1. TABEL KATEGORI
    await db.execute('''
      CREATE TABLE kategori (
        kategori_id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        tipe TEXT CHECK(tipe IN ('PEMASUKAN', 'PENGELUARAN'))
      )
    ''');

    // 2. TABEL TABUNGAN
    await db.execute('''
      CREATE TABLE tabungan (
        tabungan_id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        target_jumlah REAL NOT NULL,
        jumlah REAL DEFAULT 0,
      )
    ''');

    // 3. TABEL SALDO
    await db.execute('''
      CREATE TABLE saldo (
        saldo_id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        total INTEGER DEFAULT 0
      )
    ''');

    // 4. TABEL TRANSAKSI
    await db.execute('''
      CREATE TABLE transaksi (
        transaksi_id INTEGER PRIMARY KEY AUTOINCREMENT,
        saldo_id INTEGER NOT NULL,
        kategori_id INTEGER NOT NULL,
        tabungan_id INTEGER,
        jumlah REAL NOT NULL,
        tanggal TEXT DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (saldo_id) REFERENCES saldo (saldo_id) 
          ON DELETE CASCADE ON UPDATE NO ACTION,
        FOREIGN KEY (kategori_id) REFERENCES kategori (kategori_id) 
          ON DELETE CASCADE ON UPDATE NO ACTION,
        FOREIGN KEY (tabungan_id) REFERENCES tabungan (tabungan_id) 
          ON DELETE SET NULL ON UPDATE NO ACTION
      )
    ''');
  }
}
