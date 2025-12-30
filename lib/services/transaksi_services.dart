import 'package:saku_cerdas/db_helper.dart';
import '../models/transaksi.dart';

class TransaksiService {
  // 1. CREATE: Tambah Transaksi + Update Otomatis Saldo & Tabungan
  static Future<int> insertTransaksi(Transaksi transaksi) async {
    final db = await DBHelper.db();

    return await db.transaction((txn) async {
      // Masukkan data transaksi ke tabel sesuai nama kolom di ERD
      int id = await txn.insert('transaksi', transaksi.toMap());

      // Ambil data kategori untuk menentukan tipe (PEMASUKAN/PENGELUARAN)
      final List<Map<String, dynamic>> kategoriRes = await txn.query(
        'kategori',
        where: 'kategori_id = ?',
        whereArgs: [transaksi.kategoriId],
      );

      if (kategoriRes.isEmpty) throw Exception("Kategori tidak ditemukan");

      String tipe =
          kategoriRes.first['tipe']?.toString().toUpperCase() ?? 'PENGELUARAN';
      double jumlah = transaksi.jumlah;

      // UPDATE SALDO (Saldo_id wajib di ERD)
      if (tipe == 'PENGELUARAN') {
        await txn.execute(
          'UPDATE saldo SET total = total - ? WHERE saldo_id = ?',
          [jumlah, transaksi.saldoId],
        );
      } else {
        await txn.execute(
          'UPDATE saldo SET total = total + ? WHERE saldo_id = ?',
          [jumlah, transaksi.saldoId],
        );
      }

      // UPDATE TABUNGAN (Jika ada relasi ke tabungan)
      if (transaksi.tabunganId != null) {
        // Logika: Jika pengeluaran ke kategori tabungan, maka jumlah tabungan bertambah
        if (tipe == 'PENGELUARAN') {
          await txn.execute(
            'UPDATE tabungan SET jumlah = jumlah + ? WHERE tabungan_id = ?',
            [jumlah, transaksi.tabunganId],
          );
        } else {
          // Jika pemasukan dari klaim tabungan, jumlah tabungan berkurang
          await txn.execute(
            'UPDATE tabungan SET jumlah = jumlah - ? WHERE tabungan_id = ?',
            [jumlah, transaksi.tabunganId],
          );
        }
      }

      return id;
    });
  }

  // 2. READ ALL: Ambil Semua Transaksi dengan Join agar data lengkap
  static Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    final db = await DBHelper.db();

    // Query disesuaikan dengan nama tabel di ERD (transaksi, bukan transactions)
    return await db.rawQuery('''
      SELECT 
        t.*, 
        k.nama as nama_kategori, 
        k.tipe,
        s.nama as nama_saldo,
        tb.nama as nama_tabungan
      FROM transaksi t
      INNER JOIN kategori k ON t.kategori_id = k.kategori_id
      INNER JOIN saldo s ON t.saldo_id = s.saldo_id
      LEFT JOIN tabungan tb ON t.tabungan_id = tb.tabungan_id
      ORDER BY t.tanggal DESC
    ''');
  }

  // 3. READ BY ID
  static Future<Transaksi?> getTransaksiById(int id) async {
    final db = await DBHelper.db();
    final result = await db.query(
      'transaksi',
      where: 'transaksi_id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Transaksi.fromMap(result.first);
    }
    return null;
  }

  // 4. DELETE: Hapus Transaksi (Catatan: Idealnya saldo harus dikembalikan sebelum hapus)
  static Future<int> deleteTransaksi(int id) async {
    final db = await DBHelper.db();
    return await db.delete(
      'transaksi',
      where: 'transaksi_id = ?',
      whereArgs: [id],
    );
  }
}
