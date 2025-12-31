import 'package:flutter/material.dart';

import 'dashboard_page.dart';
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

  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
    4: GlobalKey<NavigatorState>(),
  };

  void _onSaveSuccess() {
    setState(() {
      _selectedIndex = 1;
    });
    _navigatorKeys[1]?.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final navigatorState = _navigatorKeys[_selectedIndex]?.currentState;
        if (navigatorState != null && navigatorState.canPop()) {
          navigatorState.pop();
          return false;
        }
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            TambahTransaksiPage(onSaveSuccess: _onSaveSuccess),
            _buildOffstageNavigator(3),
            _buildOffstageNavigator(4),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 2) {
              setState(() {
                _selectedIndex = index;
              });
              return;
            }
            if (_selectedIndex == index) {
              _navigatorKeys[index]?.currentState?.popUntil((route) => route.isFirst);
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
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
      ),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const DashboardPage();
        break;
      case 1:
        page = const TransaksiPage();
        break;
      case 3:
        page = const TabunganPage();
        break;
      case 4:
        page = const MenuPage();
        break;
      default:
        page = Container();
    }
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => page,
          );
        },
      ),
    );
  }
}
