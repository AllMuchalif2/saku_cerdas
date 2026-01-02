import '../db_helper.dart';
import '../models/tabungan.dart';

class TabunganService {
  // CREATE
  static Future<int> insertTabungan(Tabungan tabungan) async {
    final db = await DBHelper.db();
    return await db.insert('tabungan', tabungan.toMap());
  }

  // READ ALL
  static Future<List<Tabungan>> getAllTabungan() async {
    final db = await DBHelper.db();
    final result = await db.query('tabungan', orderBy: 'tabungan_id DESC');
    return result.map((e) => Tabungan.fromMap(e)).toList();
  }

  // READ BY ID
  static Future<Tabungan?> getTabunganById(int id) async {
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

  // UPDATE DATA
  static Future<int> updateTabungan(Tabungan tabungan) async {
    final db = await DBHelper.db();
    return await db.update(
      'tabungan',
      tabungan.toMap(),
      where: 'tabungan_id = ?',
      whereArgs: [tabungan.tabunganId],
    );
  }

  // 🔥 UPDATE SALDO DARI TRANSAKSI
  static Future<void> updateSaldoDariTransaksi({
    required int tabunganId,
    required double nominal,
    required bool isPemasukan,
  }) async {
    final db = await DBHelper.db();

    if (isPemasukan) {
      await db.rawUpdate(
        'UPDATE tabungan SET jumlah = jumlah + ? WHERE tabungan_id = ?',
        [nominal, tabunganId],
      );
    } else {
      await db.rawUpdate(
        'UPDATE tabungan SET jumlah = jumlah - ? WHERE tabungan_id = ?',
        [nominal, tabunganId],
      );
    }
  }

  // DELETE
  static Future<int> deleteTabungan(int id) async {
    final db = await DBHelper.db();
    return await db.delete(
      'tabungan',
      where: 'tabungan_id = ?',
      whereArgs: [id],
    );
  }
}
