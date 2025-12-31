import 'package:flutter/foundation.dart';
import '../db_helper.dart';
import '../models/transaksi.dart';

class TransaksiService {
  // 1. CREATE: Tambah Transaksi + Update Otomatis Saldo & Tabungan
  static Future<int> insertTransaksi(Transaksi transaksi) async {
    final db = await DBHelper.db();

    try {
      return await db.transaction((txn) async {
        // Ambil map dari model
        Map<String, dynamic> data = transaksi.toMap();

        // PENTING: Hapus transaksi_id agar tidak konflik dengan AUTOINCREMENT SQLite
        // Ini sering menjadi penyebab layar hitam/crash jika bernilai null
        data.remove('transaksi_id');

        // Masukkan data transaksi
        int id = await txn.insert('transaksi', data);

        // Ambil data kategori untuk menentukan tipe (PEMASUKAN/PENGELUARAN)
        final List<Map<String, dynamic>> kategoriRes = await txn.query(
          'kategori',
          where: 'kategori_id = ?',
          whereArgs: [transaksi.kategoriId],
        );

        if (kategoriRes.isEmpty) {
          throw Exception(
              "Kategori dengan ID ${transaksi.kategoriId} tidak ditemukan");
        }

        String tipe = kategoriRes.first['tipe']?.toString().toUpperCase() ??
            'PENGELUARAN';
        double jumlah = transaksi.jumlah;

        // UPDATE SALDO
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

        // UPDATE TABUNGAN (Jika dipilih)
        if (transaksi.tabunganId != null) {
          if (tipe == 'PENGELUARAN') {
            // Jika belanja/pengeluaran dialokasikan ke tabungan, saldo tabungan bertambah
            await txn.execute(
              'UPDATE tabungan SET jumlah = jumlah + ? WHERE tabungan_id = ?',
              [jumlah, transaksi.tabunganId],
            );
          } else {
            // Jika pemasukan ditarik dari tabungan, saldo tabungan berkurang
            await txn.execute(
              'UPDATE tabungan SET jumlah = jumlah - ? WHERE tabungan_id = ?',
              [jumlah, transaksi.tabunganId],
            );
          }
        }

        return id;
      });
    } catch (e) {
      // Mencetak error ke console agar bisa dilacak
      debugPrint("Error pada insertTransaksi: $e");
      // Melempar error kembali agar ditangkap oleh Try-Catch di UI (Halaman Tambah)
      rethrow;
    }
  }

  // 2. READ ALL: Ambil Semua Transaksi dengan Join
  static Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    try {
      final db = await DBHelper.db();
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
    } catch (e) {
      debugPrint("Error pada getAllTransaksi: $e");
      return [];
    }
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

  // 4. DELETE: Hapus Transaksi + Kembalikan Saldo (Opsional tapi disarankan)
  static Future<int> deleteTransaksi(int id) async {
    final db = await DBHelper.db();

    try {
      return await db.transaction((txn) async {
        // Ambil data transaksi sebelum dihapus untuk tahu jumlahnya
        final List<Map<String, dynamic>> trx = await txn
            .query('transaksi', where: 'transaksi_id = ?', whereArgs: [id]);

        if (trx.isNotEmpty) {
          final double jumlah = (trx.first['jumlah'] as num).toDouble();
          final int saldoId = trx.first['saldo_id'];
          final int katId = trx.first['kategori_id'];

          // Cari tipe kategorinya
          final List<Map<String, dynamic>> kat = await txn
              .query('kategori', where: 'kategori_id = ?', whereArgs: [katId]);

          if (kat.isNotEmpty) {
            String tipe = kat.first['tipe'].toString().toUpperCase();
            // Kembalikan saldo (kebalikan dari saat insert)
            if (tipe == 'PENGELUARAN') {
              await txn.execute(
                  'UPDATE saldo SET total = total + ? WHERE saldo_id = ?',
                  [jumlah, saldoId]);
            } else {
              await txn.execute(
                  'UPDATE saldo SET total = total - ? WHERE saldo_id = ?',
                  [jumlah, saldoId]);
            }
          }
        }

        // Baru hapus datanya
        return await txn.delete(
          'transaksi',
          where: 'transaksi_id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      debugPrint("Error pada deleteTransaksi: $e");
      return 0;
    }
  }
}
