import 'package:flutter/material.dart';
import 'dart:async';
import '../services/kategori_service.dart';
import '../services/saldo_service.dart';
import '../services/transaksi_service.dart';
import '../services/tabungan_service.dart';

import './kategori_page.dart';
import './saldo_page.dart';
import './about_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _countKategori = 0;
  int _countSaldo = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final kategoriList = await KategoriService.getAllKategori();
      final saldoList = await SaldoService.getAllSaldo();

      if (mounted) {
        setState(() {
          _countKategori = kategoriList.length;
          _countSaldo = saldoList.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint("Error loading counts: $e");
    }
  }

  //Notif
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
              mainAxisSize: MainAxisSize.min, // Ukuran menyesuaikan isi
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

  // --- LOGIKA HAPUS DATA ---

  // 1. Menampilkan Menu Pengaturan
  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Pengaturan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  "Hapus Semua Data",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text("Reset aplikasi ke pengaturan awal"),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // 2. Dialog Konfirmasi
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Semua Data?"),
        content: const Text(
            "Tindakan ini tidak dapat dibatalkan. Semua data (Transaksi, Tabungan, Kategori, Saldo) akan hilang permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _performDeleteAll(); // Jalankan penghapusan
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 3. Proses Penghapusan Data (DIPERBARUI DENGAN NOTIFIKASI TENGAH)
  Future<void> _performDeleteAll() async {
    setState(() => _isLoading = true);
    try {
      await TransaksiService.deleteAllTransaksi();
      await TabunganService.deleteAllTabungan();
      await KategoriService.deleteAllKategori();
      await SaldoService.deleteAllSaldo();

      if (mounted) {
        _loadCounts();

        // Panggil Notifikasi Tengah (Sukses)
        _showCenterNotif("Semua data berhasil dihapus (Reset Total)",
            success: true);
      }
    } catch (e) {
      debugPrint("Error deleting data: $e");
      if (mounted) {
        setState(() => _isLoading = false);

        // Panggil Notifikasi Tengah (Gagal)
        _showCenterNotif("Gagal menghapus data: $e", success: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Colors.teal;
    const colorSecondary = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Lainnya"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Manajemen Data",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Card Kategori
                      _buildMenuCard(
                        context,
                        title: "Kategori",
                        count: _countKategori,
                        icon: Icons.category_rounded,
                        color: colorPrimary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const KategoriPage()),
                          ).then((_) => _loadCounts());
                        },
                      ),
                      const SizedBox(width: 16),
                      // Card Saldo
                      _buildMenuCard(
                        context,
                        title: "Saldo",
                        count: _countSaldo,
                        icon: Icons.account_balance_wallet_rounded,
                        color: colorSecondary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SaldoPage()),
                          ).then((_) => _loadCounts());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Pengaturan Aplikasi"),
                    onTap: _showSettingsMenu,
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text("Tentang Saku Cerdas"),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AboutPage()));
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "$count Item",
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
