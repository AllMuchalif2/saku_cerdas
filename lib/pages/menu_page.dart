import 'package:flutter/material.dart';
import '../services/kategori_service.dart';
import '../services/saldo_service.dart';

// Tambahkan import halaman tujuan di sini
import './kategori_page.dart';
import './saldo_page.dart';

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
                      // Card Kategori dengan navigasi ke KategoriPage
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
                          ).then((_) =>
                              _loadCounts()); // Refresh jumlah setelah kembali
                        },
                      ),
                      const SizedBox(width: 16),
                      // Card Saldo dengan navigasi ke SaldoPage
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
                              builder: (context) => const SaldoPage(),
                            ),
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
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text("Tentang Saku Cerdas"),
                    onTap: () {},
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
