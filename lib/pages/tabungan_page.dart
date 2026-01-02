import 'package:flutter/material.dart';
import '../models/tabungan.dart';
import '../services/tabungan_service.dart';

class TabunganPage extends StatefulWidget {
  const TabunganPage({super.key});

  @override
  State<TabunganPage> createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage> {
  // Controller untuk Form
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  // Helper untuk format angka ke Rupiah sederhana
  String _formatRupiah(double number) {
    return "Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // Merefresh tampilan setelah CRUD (memanggil setState agar FutureBuilder jalan ulang)
  void _refreshData() {
    setState(() {});
  }

  // Fungsi Menambah/Edit Tabungan ke Database
  Future<void> _simpanTabungan({Tabungan? tabungan}) async {
    final String nama = _namaController.text;
    final double target = double.tryParse(_targetController.text) ?? 0;
    // Jumlah biasanya otomatis dari transaksi, tapi kita izinkan edit manual saat inisialisasi
    final double jumlah = double.tryParse(_jumlahController.text) ?? 0;

    if (nama.isNotEmpty && target > 0) {
      bool isEdit = tabungan != null;

      if (isEdit) {
        // UPDATE DATA
        Tabungan updateTabungan = Tabungan(
          tabunganId: tabungan.tabunganId,
          nama: nama,
          targetJumlah: target,
          jumlah: jumlah,
        );
        await TabunganService.updateTabungan(updateTabungan);
      } else {
        // INSERT DATA BARU
        Tabungan newTabungan = Tabungan(
          nama: nama,
          targetJumlah: target,
          jumlah: jumlah,
        );
        await TabunganService.insertTabungan(newTabungan);
      }

      if (!mounted) return;
      Navigator.pop(context); // Tutup Dialog
      _refreshData(); // Refresh List
    }
  }

  // Fungsi Hapus dari Database
  Future<void> _hapusTabungan(int id) async {
    await TabunganService.deleteTabungan(id);
    if (!mounted) return;
    Navigator.pop(context); // Tutup Dialog Konfirmasi
    _refreshData(); // Refresh List
  }

  // UI Dialog Form
  void _showFormDialog({Tabungan? tabungan}) {
    final bool isEdit = tabungan != null;

    if (isEdit) {
      _namaController.text = tabungan.nama;
      _targetController.text = tabungan.targetJumlah.toStringAsFixed(0);
      _jumlahController.text = tabungan.jumlah.toStringAsFixed(0);
    } else {
      _namaController.clear();
      _targetController.clear();
      _jumlahController.text = "0";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEdit ? "Edit Tabungan" : "Tambah Tabungan",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Tabungan",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Target Jumlah (Rp)",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Saldo Terkumpul (Rp)",
                    helperText: "Diisi jika sudah ada tabungan awal",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // ===== TOMBOL BATAL =====
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text("Batal"),
            ),

            // ===== TOMBOL SIMPAN =====
            ElevatedButton(
              onPressed: () => _simpanTabungan(tabungan: tabungan),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // UI Dialog Hapus
  void _showDeleteDialog(Tabungan tabungan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Tabungan?"),
        content: Text("Anda yakin ingin menghapus '${tabungan.nama}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => _hapusTabungan(tabungan.tabunganId!),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Tabungan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // Menggunakan FutureBuilder untuk mengambil data dari Database
      body: FutureBuilder<List<Tabungan>>(
        future: TabunganService.getAllTabungan(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada target tabungan."));
          }

          // 4. Data State
          final listTabungan = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: listTabungan.length,
            itemBuilder: (context, index) {
              final item = listTabungan[index];

              // Menghitung persentase progress (0.0 sampai 1.0)
              double progress = item.targetJumlah > 0
                  ? (item.jumlah / item.targetJumlah)
                  : 0.0;
              // Clamp agar tidak error visual jika lebih dari 100%
              double displayProgress = progress > 1.0 ? 1.0 : progress;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Nama dan Menu Option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.nama,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showFormDialog(tabungan: item);
                              } else if (value == 'delete') {
                                _showDeleteDialog(item);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text("Edit")
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text("Hapus")
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: displayProgress,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          color: progress >= 1.0 ? Colors.green : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Detail Angka
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatRupiah(item.jumlah),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Target: ${_formatRupiah(item.targetJumlah)}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${(progress * 100).toStringAsFixed(1)}% Terkumpul",
                        style: TextStyle(
                            fontSize: 12,
                            color: progress >= 1.0
                                ? Colors.green
                                : Colors.grey[600],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _targetController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }
}
