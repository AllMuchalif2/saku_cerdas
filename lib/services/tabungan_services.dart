import 'package:saku_cerdas/db_helper.dart';

import '../models/tabungan.dart';

class TabunganService {
  // CREATE
  Future<int> insertTabungan(Tabungan tabungan) async {
    final db = await DBHelper.db();
    return await db.insert('tabungan', tabungan.toMap());
  }

  // READ ALL
  Future<List<Tabungan>> getAllTabungan() async {
    final db = await DBHelper.db();
    final result = await db.query('tabungan', orderBy: 'tabungan_id DESC');

    return result.map((e) => Tabungan.fromMap(e)).toList();
  }

  // READ BY ID
  Future<Tabungan?> getTabunganById(int id) async {
    final db = await DBHelper.db();
    final result = await db.query(
      'tabungan',
      where: 'tabungan_id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Tabungan.fromMap(result.first);
    }
    return null;
  }

  // UPDATE
  Future<int> updateTabungan(Tabungan tabungan) async {
    final db = await DBHelper.db();
    return await db.update(
      'tabungan',
      tabungan.toMap(),
      where: 'tabungan_id = ?',
      whereArgs: [tabungan.tabunganId],
    );
  }

  // UPDATE JUMLAH TABUNGAN (dipakai saat transaksi)
  Future<int> updateJumlahTabungan(int tabunganId, double jumlahBaru) async {
    final db = await DBHelper.db();
    return await db.update(
      'tabungan',
      {'jumlah': jumlahBaru},
      where: 'tabungan_id = ?',
      whereArgs: [tabunganId],
    );
  }

  // DELETE
  Future<int> deleteTabungan(int id) async {
    final db = await DBHelper.db();
    return await db.delete(
      'tabungan',
      where: 'tabungan_id = ?',
      whereArgs: [id],
    );
  }
}
