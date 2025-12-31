import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saku_cerdas/services/transaksi_service.dart';
import 'package:saku_cerdas/pages/tambah_transaksi_page.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  // PERBAIKAN: Gunakan 'num' agar bisa menerima int maupun double
  String formatRupiah(num nominal) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(nominal);
  }

  void _refreshData() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // FutureBuilder akan memanggil ulang fungsi ini setiap kali setState dipanggil
        future: TransaksiService.getAllTransaksi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Terjadi kesalahan: ${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada transaksi.'));
          }

          final listTransaksi = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: listTransaksi.length,
            itemBuilder: (context, index) {
              final item = listTransaksi[index];
              try {
                // PROTEKSI DATA NULL & TYPE CASTING
                final String tipeRaw =
                    item['tipe']?.toString() ?? 'PENGELUARAN';
                final String tipe = tipeRaw.toUpperCase();
                final bool isPemasukan = tipe == 'PEMASUKAN';

                final String namaSaldo = item['nama_saldo'] ?? 'Saldo';
                final String namaKategori = item['nama_kategori'] ?? 'Kategori';

                // PERBAIKAN: Konversi paksa ke double agar tidak error subtype
                final double jumlah =
                    (item['jumlah'] as num?)?.toDouble() ?? 0.0;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isPemasukan ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isPemasukan ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      namaKategori,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item['tanggal'] ?? '-'} • $namaSaldo",
                            style: const TextStyle(fontSize: 12)),

                        // Cek apakah ada data tabungan (Join berhasil)
                        if (item['nama_tabungan'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                "🎯 Tabungan: ${item['nama_tabungan']}",
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Text(
                      (isPemasukan ? "+ " : "- ") + formatRupiah(jumlah),
                      style: TextStyle(
                        color: isPemasukan ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onLongPress: () {
                      _konfirmasiHapus(item['transaksi_id']);
                    },
                  ),
                );
              } catch (e, s) {
                debugPrint('Error building list item: $e');
                debugPrint('$s');
                return Card(
                  color: Colors.red[50],
                  child: ListTile(
                    title: Text('Error rendering transaksi #$index'),
                    subtitle: Text(e.toString()),
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi dan tunggu kembalian dari pop(context, true)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TambahTransaksiPage()),
          );
          debugPrint('TambahTransaksi returned: $result');

          // Jika result true, panggil _refreshData untuk trigger FutureBuilder
          if (result == true) {
            _refreshData();
            // Tampilkan notifikasi sukses menggunakan konteks pemanggil (aman)
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaksi Berhasil Disimpan')),
              );
            }
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _konfirmasiHapus(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text(
            'Menghapus riwayat akan mengupdate saldo kembali seperti semula.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await TransaksiService.deleteTransaksi(id);
                if (!mounted) return;
                Navigator.pop(context); // Tutup dialog
                _refreshData(); // Refresh list

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi dihapus')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
