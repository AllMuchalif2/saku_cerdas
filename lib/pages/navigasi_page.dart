import 'package:flutter/material.dart';

import 'package:saku_cerdas/pages/dashboard_page.dart';
import 'package:saku_cerdas/pages/transaksi_page.dart';
import 'package:saku_cerdas/pages/tambah_transaksi_page.dart';
import 'package:saku_cerdas/pages/tabungan_page.dart';
import 'package:saku_cerdas/pages/menu_page.dart';
// import 'ringkasan.dart';
// import 'transaksi.dart';
// import 'tambah_transaksi.dart';
// import 'tabungan.dart';
// import 'menu_lainnya.dart';

class NavigasiPage extends StatefulWidget {
  const NavigasiPage({Key? key}) : super(key: key);

  @override
  State<NavigasiPage> createState() => _NavigasiPageState();
}

class _NavigasiPageState extends State<NavigasiPage> {
  int _selectedIndex = 0;

  // Daftar 5 halaman utama
  final List<Widget> _pages = [
    const DashboardPage(),
    const TransaksiPage(),
    const TambahTransaksiPage(),
    const TabunganPage(),
    const MenuPage(),
    // const TambahTransaksiScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40, color: Colors.blueAccent),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            activeIcon: Icon(Icons.savings),
            label: 'Tabungan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
