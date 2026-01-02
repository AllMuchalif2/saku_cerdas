import '../db_helper.dart';
import '../models/tabungan.dart';

class TabunganService {
  // 1. Tambahkan variabel ini (Callback trigger)
  // Tidak butuh import foundation.dart
  static Function()? onDataChanged;

  // CREATE
  static Future<int> insertTabungan(Tabungan tabungan) async {
    final db = await DBHelper.db();
    int res = await db.insert('tabungan', tabungan.toMap());
    onDataChanged?.call(); // Optional: Refresh saat insert
    return res;
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
    int res = await db.update(
      'tabungan',
      tabungan.toMap(),
      where: 'tabungan_id = ?',
      whereArgs: [tabungan.tabunganId],
    );
    onDataChanged?.call(); // Optional: Refresh saat edit
    return res;
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

    // 2. Panggil trigger refresh disini
    // Tanda ?. berarti "jalankan jika ada yg mendengarkan (TabunganPage sedang aktif)"
    onDataChanged?.call();
  }

  // DELETE
  static Future<int> deleteTabungan(int id) async {
    final db = await DBHelper.db();
    int res = await db.delete(
      'tabungan',
      where: 'tabungan_id = ?',
      whereArgs: [id],
    );
    onDataChanged?.call(); // Optional: Refresh saat hapus
    return res;
  }

  static Future<void> deleteAllTabungan() async {
    final db = await DBHelper.db();
    await db.delete('tabungan');
    onDataChanged?.call();
  }
}
