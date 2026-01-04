import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kategori.dart';
import '../models/saldo.dart';
import '../models/tabungan.dart';

class GroqService {
  // Ganti dengan URL Vercel Anda
  static const String _baseUrl =
      'https://groq-for-transaksiku-5e90uvit4-allmuchalif2s-projects.vercel.app/api/chat';
  static const String _appSecret = 'u-didnt-even-know';

  static Future<Map<String, dynamic>?> extractTransaction({
    required String message,
    required List<KategoriModel> kategoriList,
    required List<Saldo> saldoList,
    required List<Tabungan> tabunganList,
  }) async {
    try {
      // 1. Siapkan data context agar AI tahu ID yang tersedia
      final List<Map<String, dynamic>> kategoriJson = kategoriList
          .map((k) => {
                'kategori_id': k.kategoriId,
                'nama': k.nama,
                'tipe': k.tipe,
              })
          .toList();

      final List<Map<String, dynamic>> saldoJson = saldoList
          .map((s) => {
                'saldo_id': s.saldoId,
                'nama': s.nama,
              })
          .toList();

      final List<Map<String, dynamic>> tabunganJson = tabunganList
          .map((t) => {
                'tabungan_id': t.tabunganId,
                'nama': t.nama,
              })
          .toList();

      // 2. Buat Body Request
      final body = jsonEncode({
        'message': message,
        'kategori': kategoriJson,
        'saldo': saldoJson,
        'tabungan': tabunganJson,
      });

      // 3. Kirim Request ke Backend
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-app-secret': _appSecret,
        },
        body: body,
      );

      // 4. Proses Response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        }
      }

      return null;
    } catch (e) {
      print("Error GroqService: $e");
      return null;
    }
  }
}
