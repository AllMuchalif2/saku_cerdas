import 'package:flutter/foundation.dart';
import '../db_helper.dart';
import '../models/transaksi.dart';

class TransaksiService {
  // 1. CREATE: Tambah Transaksi + Update Otomatis Saldo & Tabungan
  static Future<int> insertTransaksi(Transaksi transaksi) async {
    final db = await DBHelper.db();

    try {
      return await db.transaction((txn) async {
        Map<String, dynamic> data = transaksi.toMap();
        data.remove('transaksi_id');

        int id = await txn.insert('transaksi', data);

        // Ambil data kategori untuk menentukan tipe
        final List<Map<String, dynamic>> kategoriRes = await txn.query(
          'kategori',
          where: 'kategori_id = ?',
          whereArgs: [transaksi.kategoriId],
        );

        if (kategoriRes.isEmpty) {
          throw Exception("Kategori tidak ditemukan");
        }

        String tipe = kategoriRes.first['tipe']?.toString().toUpperCase() ??
            'PENGELUARAN';
        double jumlah = transaksi.jumlah;

        // UPDATE SALDO
        if (tipe == 'PENGELUARAN') {
          await txn.execute(
              'UPDATE saldo SET total = total - ? WHERE saldo_id = ?',
              [jumlah, transaksi.saldoId]);
        } else {
          await txn.execute(
              'UPDATE saldo SET total = total + ? WHERE saldo_id = ?',
              [jumlah, transaksi.saldoId]);
        }

        // UPDATE TABUNGAN (Jika ada)
        if (transaksi.tabunganId != null) {
          // Logika diperbaiki: Pemasukan menambah tabungan, pengeluaran mengurangi.
          if (tipe == 'PEMASUKAN') {
            await txn.execute(
                'UPDATE tabungan SET jumlah = jumlah + ? WHERE tabungan_id = ?',
                [jumlah, transaksi.tabunganId]);
          } else {
            // PENGELUARAN
            await txn.execute(
                'UPDATE tabungan SET jumlah = jumlah - ? WHERE tabungan_id = ?',
                [jumlah, transaksi.tabunganId]);
          }
        }
        return id;
      });
    } catch (e) {
      debugPrint("Error pada insertTransaksi: $e");
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

  // 4. UPDATE LENGKAP: Menangani perubahan field termasuk TABUNGAN
  static Future<void> updateTransaksiLengkap({
    required int id,
    required String nama,
    required double jumlah,
    required int kategoriId,
    required int saldoId,
    int? tabunganId, // SEKARANG SUDAH MENDUKUNG TABUNGAN
    required String tanggal,
  }) async {
    final db = await DBHelper.db();

    try {
      await db.transaction((txn) async {
        // A. Ambil data lama untuk REVERSE (Membatalkan) efek saldo sebelumnya
        final List<Map<String, dynamic>> trxLama = await txn.query(
          'transaksi',
          where: 'transaksi_id = ?',
          whereArgs: [id],
        );

        if (trxLama.isEmpty) throw Exception("Transaksi tidak ditemukan");

        double oldJumlah = (trxLama.first['jumlah'] as num).toDouble();
        int oldSaldoId = trxLama.first['saldo_id'];
        int oldKatId = trxLama.first['kategori_id'];
        int? oldTabId = trxLama.first['tabungan_id'];

        final List<Map<String, dynamic>> katLamaRes = await txn.query(
          'kategori',
          where: 'kategori_id = ?',
          whereArgs: [oldKatId],
        );
        String oldTipe = katLamaRes.first['tipe'].toString().toUpperCase();

        // --- PROSES REVERSE (KEMBALIKAN SALDO LAMA) ---
        if (oldTipe == 'PENGELUARAN') {
          await txn.execute(
              'UPDATE saldo SET total = total + ? WHERE saldo_id = ?',
              [oldJumlah, oldSaldoId]);
          if (oldTabId != null) {
            await txn.execute(
                'UPDATE tabungan SET jumlah = jumlah + ? WHERE tabungan_id = ?',
                [oldJumlah, oldTabId]);
          }
        } else {
          // PEMASUKAN
          await txn.execute(
              'UPDATE saldo SET total = total - ? WHERE saldo_id = ?',
              [oldJumlah, oldSaldoId]);
          if (oldTabId != null) {
            await txn.execute(
                'UPDATE tabungan SET jumlah = jumlah - ? WHERE tabungan_id = ?',
                [oldJumlah, oldTabId]);
          }
        }

        // B. Terapkan efek DATA BARU
        final List<Map<String, dynamic>> katBaruRes = await txn.query(
          'kategori',
          where: 'kategori_id = ?',
          whereArgs: [kategoriId],
        );
        String newTipe = katBaruRes.first['tipe'].toString().toUpperCase();

        if (newTipe == 'PENGELUARAN') {
          await txn.execute(
              'UPDATE saldo SET total = total - ? WHERE saldo_id = ?',
              [jumlah, saldoId]);
          if (tabunganId != null) {
            await txn.execute(
                'UPDATE tabungan SET jumlah = jumlah - ? WHERE tabungan_id = ?',
                [jumlah, tabunganId]);
          }
        } else {
          // PEMASUKAN
          await txn.execute(
              'UPDATE saldo SET total = total + ? WHERE saldo_id = ?',
              [jumlah, saldoId]);
          if (tabunganId != null) {
            await txn.execute(
                'UPDATE tabungan SET jumlah = jumlah + ? WHERE tabungan_id = ?',
                [jumlah, tabunganId]);
          }
        }

        // C. Update data di tabel transaksi
        await txn.update(
          'transaksi',
          {
            'nama': nama,
            'jumlah': jumlah,
            'kategori_id': kategoriId,
            'saldo_id': saldoId,
            'tabungan_id': tabunganId, // SEKARANG TERUPDATE DI DB
            'tanggal': tanggal,
          },
          where: 'transaksi_id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      debugPrint("Error pada updateTransaksiLengkap: $e");
      rethrow;
    }
  }

  // 5. DELETE: Hapus Transaksi + Kembalikan Saldo
  static Future<int> deleteTransaksi(int id) async {
    final db = await DBHelper.db();

    try {
      return await db.transaction((txn) async {
        final List<Map<String, dynamic>> trx = await txn
            .query('transaksi', where: 'transaksi_id = ?', whereArgs: [id]);

        if (trx.isNotEmpty) {
          final double jumlah = (trx.first['jumlah'] as num).toDouble();
          final int saldoId = trx.first['saldo_id'];
          final int katId = trx.first['kategori_id'];
          final int? tabunganId = trx.first['tabungan_id'];

          final List<Map<String, dynamic>> kat = await txn
              .query('kategori', where: 'kategori_id = ?', whereArgs: [katId]);

          if (kat.isNotEmpty) {
            String tipe = kat.first['tipe'].toString().toUpperCase();

            // Membalikkan logika: hapus pemasukan akan mengurangi saldo, hapus pengeluaran akan menambah.
            if (tipe == 'PENGELUARAN') {
              await txn.execute(
                  'UPDATE saldo SET total = total + ? WHERE saldo_id = ?',
                  [jumlah, saldoId]);
              if (tabunganId != null) {
                await txn.execute(
                    'UPDATE tabungan SET jumlah = jumlah + ? WHERE tabungan_id = ?',
                    [jumlah, tabunganId]);
              }
            } else {
              // PEMASUKAN
              await txn.execute(
                  'UPDATE saldo SET total = total - ? WHERE saldo_id = ?',
                  [jumlah, saldoId]);
              if (tabunganId != null) {
                await txn.execute(
                    'UPDATE tabungan SET jumlah = jumlah - ? WHERE tabungan_id = ?',
                    [jumlah, tabunganId]);
              }
            }
          }
        }

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

  static Future<void> deleteAllTransaksi() async {
    final db = await DBHelper.db();
    await db.delete('transaksi');
  }
}
