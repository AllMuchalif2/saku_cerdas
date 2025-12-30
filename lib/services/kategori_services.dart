import 'package:sqflite/sqflite.dart';
import 'package:saku_cerdas/db_helper.dart';
import 'package:saku_cerdas/models/kategori.dart';

class KategoriService {
  // CREATE
  Future<int> addKategori(KategoriModel kategori) async {
    final db = await DBHelper.db();
    return await db.insert(
      'kategori',
      kategori.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL
  Future<List<KategoriModel>> getAllKategori() async {
    final db = await DBHelper.db();
    final List<Map<String, dynamic>> maps = await db.query('kategori');

    return List.generate(maps.length, (i) {
      return KategoriModel.fromMap(maps[i]);
    });
  }

  // READ TIPE
  Future<List<KategoriModel>> getKategoriByTipe(String tipe) async {
    final db = await DBHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'tipe = ?',
      whereArgs: [tipe],
    );

    return maps.map((e) => KategoriModel.fromMap(e)).toList();
  }

  // UPDATE
  Future<int> updateKategori(KategoriModel kategori) async {
    final db = await DBHelper.db();
    return await db.update(
      'kategori',
      kategori.toMap(),
      where: 'kategori_id = ?',
      whereArgs: [kategori.kategoriId],
    );
  }

  // DELETE
  Future<int> deleteKategori(int id) async {
    final db = await DBHelper.db();
    return await db.delete(
      'kategori',
      where: 'kategori_id = ?',
      whereArgs: [id],
    );
  }
}
