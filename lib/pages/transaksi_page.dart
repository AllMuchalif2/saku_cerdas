import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaksi_services.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  // Menggunakan double karena di ERD bertipe REAL
  String formatRupiah(double nominal) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(nominal);
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
        future: TransaksiService.getAllTransaksi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
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

              // Tipe diambil dari tabel kategori hasil JOIN di service
              final String tipe =
                  item['tipe']?.toString().toUpperCase() ?? 'PENGELUARAN';
              final bool isPemasukan = tipe == 'PEMASUKAN';

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
                    item['nama_kategori'] ?? 'Tanpa Kategori',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['tanggal'] ?? '-'),
                      if (item['nama_tabungan'] != null)
                        Text(
                          "Tabungan: ${item['nama_tabungan']}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.blueGrey),
                        ),
                    ],
                  ),
                  trailing: Text(
                    (isPemasukan ? "+ " : "- ") +
                        formatRupiah((item['jumlah'] as num).toDouble()),
                    style: TextStyle(
                      color: isPemasukan ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onLongPress: () {
                    // Gunakan transaksi_id sesuai ERD
                    _konfirmasiHapus(item['transaksi_id']);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman tambah transaksi
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
        content: const Text('Saldo akan otomatis disesuaikan kembali.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await TransaksiService.deleteTransaksi(id);
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {}); // Segarkan tampilan
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
