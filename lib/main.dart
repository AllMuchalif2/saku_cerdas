import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:saku_cerdas/pages/navigasi_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saku Cerdas',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4300FF),
          primary: const Color(0xFF4300FF),
          secondary: const Color(0xFF0065F8),
          tertiary: const Color(0xFF00CAFF),
          surface: const Color(0xffd4fffa),
        ),
      ),
      home: const NavigasiPage(),
    );
  }
}
