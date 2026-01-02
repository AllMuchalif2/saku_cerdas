import 'package:flutter/material.dart';

import 'home_page.dart';
import 'transaksi_page.dart';
import 'tambah_transaksi_page.dart';
import 'tabungan_page.dart';
import 'menu_page.dart';

class NavigasiPage extends StatefulWidget {
  const NavigasiPage({Key? key}) : super(key: key);

  @override
  State<NavigasiPage> createState() => _NavigasiPageState();
}

class _NavigasiPageState extends State<NavigasiPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      HomePage(onNavigateToTab: (index) => _onItemTapped(index)),
      const TransaksiPage(),
      Container(), // Placeholder for the "add" button
      const TabunganPage(),
      const MenuPage(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Handle the add button tap
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TambahTransaksiPage(
            onSaveSuccess: () {
              if (mounted) {
                setState(() {
                  _selectedIndex = 1;
                });
              }
            },
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
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
            icon: Icon(Icons.add_circle, size: 40, color: Colors.teal),
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
