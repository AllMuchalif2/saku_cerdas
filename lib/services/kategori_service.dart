import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../models/kategori.dart';

class KategoriService {
  // CREATE
  static Future<int> addKategori(KategoriModel kategori) async {
    final db = await DBHelper.db();
    return await db.insert(
      'kategori',
      kategori.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // READ ALL (Hanya yang tidak di-soft delete)
  static Future<List<KategoriModel>> getAllKategori() async {
    final db = await DBHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return KategoriModel.fromMap(maps[i]);
    });
  }

  // READ TIPE (Hanya yang tidak di-soft delete)
  static Future<List<KategoriModel>> getKategoriByTipe(String tipe) async {
    final db = await DBHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'tipe = ? AND is_deleted = ?',
      whereArgs: [tipe, 0],
    );

    return maps.map((e) => KategoriModel.fromMap(e)).toList();
  }

  // UPDATE
  static Future<int> updateKategori(KategoriModel kategori) async {
    final db = await DBHelper.db();
    return await db.update(
      'kategori',
      kategori.toMap(),
      where: 'kategori_id = ?',
      whereArgs: [kategori.kategoriId],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // SOFT DELETE
  static Future<int> softDeleteKategori(int id) async {
    final db = await DBHelper.db();
    return await db.update(
      'kategori',
      {'is_deleted': 1},
      where: 'kategori_id = ?',
      whereArgs: [id],
    );
  }

  // HARD DELETE (Jika suatu saat dibutuhkan)
  static Future<int> deleteKategori(int id) async {
    final db = await DBHelper.db();
    return await db.delete(
      'kategori',
      where: 'kategori_id = ?',
      whereArgs: [id],
    );
  }
}
