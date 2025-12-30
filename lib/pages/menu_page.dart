import 'package:flutter/material.dart';
import 'package:saku_cerdas/services/kategori_services.dart';
import 'package:saku_cerdas/services/saldo_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final KategoriService _kategoriService = KategoriService();
  final SaldoService _saldoService = SaldoService();

  int _countKategori = 0;
  int _countSaldo = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  // Mengambil jumlah kategori dan saldo dari database
  Future<void> _loadCounts() async {
    try {
      final kategoriList = await _kategoriService.getAllKategori(); //
      final saldoList = await _saldoService.getAllSaldo(); //

      setState(() {
        _countKategori = kategoriList.length;
        _countSaldo = saldoList.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading counts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna sesuai permintaan Anda
    const colorPrimary = Color(0xFF4300FF);
    const colorSecondary = Color(0xFF0065F8);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Lainnya"),
        centerTitle: true,
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

                  // Baris berisi 2 Card (Kategori dan Saldo)
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
                          // Navigasi ke halaman manajemen kategori nantinya
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
                          // Navigasi ke halaman manajemen saldo nantinya
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pembatas untuk menu masa depan
                  const Divider(thickness: 1, color: Colors.grey),

                  const SizedBox(height: 16),

                  // Contoh placeholder menu tambahan di bawah pembatas
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

  // Widget pendukung untuk membuat Card Menu secara seragam
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
