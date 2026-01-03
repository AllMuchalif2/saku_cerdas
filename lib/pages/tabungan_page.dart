import 'package:flutter/material.dart';
import 'dart:async'; // Timer
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

  void _refreshData() {
    setState(() {});
  }

  // Notif
  void _showCenterNotif(String message, {bool success = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Timer otomatis menutup dialog setelah 1.5 detik
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: success ? Colors.teal : Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi Menambah/Edit Tabungan ke Database
  Future<void> _simpanTabungan({Tabungan? tabungan}) async {
    final String nama = _namaController.text.trim();
    final double target = double.tryParse(_targetController.text) ?? 0;
    final double jumlah = double.tryParse(_jumlahController.text) ?? 0;

    // --- VALIDASI DATA ---
    if (nama.isEmpty) {
      _showCenterNotif("Nama tabungan tidak boleh kosong", success: false);
      return;
    }
    if (target <= 0) {
      _showCenterNotif("Target harus lebih dari 0", success: false);
      return;
    }

    // --- PROSES SIMPAN ---
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

    // Tutup Form Dialog dulu
    Navigator.pop(context);

    // Refresh Halaman
    _refreshData();

    // Tampilkan Notifikasi Sukses di Tengah
    _showCenterNotif(
      isEdit ? "Tabungan berhasil diupdate" : "Tabungan berhasil ditambahkan",
      success: true,
    );
  }

  // Fungsi Hapus dari Database
  Future<void> _hapusTabungan(int id) async {
    await TabunganService.deleteTabungan(id);
    if (!mounted) return;

    Navigator.pop(context);
    _refreshData(); // Refresh List

    // Tampilkan Notifikasi Hapus Berhasil
    _showCenterNotif("Tabungan berhasil dihapus", success: true);
  }

  // UI Dialog Form (Tambah/Edit)
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
          title: Text(isEdit ? "Edit Tabungan" : "Tambah Tabungan"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(labelText: "Nama Tabungan"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "Target Jumlah (Rp)"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Saldo Awal (Rp)",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
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

  // UI Dialog Konfirmasi Hapus
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
      body: FutureBuilder<List<Tabungan>>(
        future: TabunganService.getAllTabungan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("Belum ada target tabungan.")),
                ],
              ),
            );
          }

          final listTabungan = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: listTabungan.length,
              itemBuilder: (context, index) {
                final item = listTabungan[index];
                double progress = item.targetJumlah > 0
                    ? (item.jumlah / item.targetJumlah)
                    : 0.0;
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
            ),
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
