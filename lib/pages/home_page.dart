import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/saldo.dart';
import '../models/tabungan.dart';

import '../services/saldo_service.dart';
import '../services/tabungan_service.dart';
import '../services/transaksi_service.dart';

import './saldo_page.dart';

import './tambah_transaksi_page.dart';
import '../widgets/chat_ai_modal.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateToTab;
  HomePage({Key? key, required this.onNavigateToTab}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Saldo> _listSaldo = [];
  List<Tabungan> _listTabungan = [];
  List<Map<String, dynamic>> _latestTransaksi = [];
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  bool _isLoading = true;
  bool _isSaldoVisible = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    // Ambil data secara paralel
    final results = await Future.wait([
      SaldoService.getAllSaldo(),
      TabunganService.getAllTabungan(),
      TransaksiService.getAllTransaksi(),
    ]);

    final allTransaksi = results[2] as List<Map<String, dynamic>>;

    // Hitung ringkasan dan ambil 3 transaksi terbaru
    double income = 0;
    double expense = 0;
    for (var t in allTransaksi) {
      if (t['tipe'] == 'PEMASUKAN') {
        income += t['jumlah'];
      } else {
        expense += t['jumlah'];
      }
    }

    if (mounted) {
      setState(() {
        _listSaldo = results[0] as List<Saldo>;
        _listTabungan = results[1] as List<Tabungan>;
        _latestTransaksi = allTransaksi.take(3).toList();
        _totalPemasukan = income;
        _totalPengeluaran = expense;
        _isLoading = false;
      });
    }
  }

  String _formatIDR(dynamic amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  // Fungsi membuka Chat AI
  void _showChatAI() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ChatAIModal(),
    );

    if (result != null && mounted) {
      // Navigate ke Form dengan data hasil AI
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TambahTransaksiPage(
            initialData: result,
            onSaveSuccess: _loadDashboardData,
          ),
        ),
      ).then((_) => _loadDashboardData());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SALDO SLIDER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Dompet Saya",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SaldoPage())),
                    child: const Text("Lihat Semua",
                        style: TextStyle(color: Colors.teal)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: _listSaldo.isEmpty
                    ? _buildEmptyState("Belum ada saldo")
                    : PageView.builder(
                        controller: PageController(viewportFraction: 0.9),
                        itemCount: _listSaldo.length,
                        itemBuilder: (context, index) {
                          final saldo = _listSaldo[index];
                          return Card(
                            color: Colors.teal,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(saldo.nama,
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          _isSaldoVisible
                                              ? _formatIDR(saldo.total)
                                              : 'Rp •••••••••',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: Icon(
                                          _isSaldoVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isSaldoVisible = !_isSaldoVisible;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 25),

              // 2. RINGKASAN PEMASUKAN & PENGELUARAN
              Row(
                children: [
                  _buildSummaryCard("Pemasukan", _totalPemasukan, Colors.green,
                      Icons.arrow_downward),
                  const SizedBox(width: 10),
                  _buildSummaryCard("Pengeluaran", _totalPengeluaran,
                      Colors.red, Icons.arrow_upward),
                ],
              ),

              const SizedBox(height: 25),

              // 3. 3 TRANSAKSI TERBARU
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Transaksi Terbaru",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                      onPressed: () => widget.onNavigateToTab(1),
                      child: const Text("Lihat Semua",
                          style: TextStyle(color: Colors.teal)))
                ],
              ),
              _latestTransaksi.isEmpty
                  ? _buildEmptyState("Belum ada transaksi")
                  : Column(
                      children: _latestTransaksi
                          .map((t) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: t['tipe'] == 'PEMASUKAN'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  child: Icon(
                                      t['tipe'] == 'PEMASUKAN'
                                          ? Icons.add
                                          : Icons.remove,
                                      color: t['tipe'] == 'PEMASUKAN'
                                          ? Colors.green
                                          : Colors.red),
                                ),
                                title: Text(t['nama_kategori']),
                                subtitle: Text(t['tanggal'] ?? ''),
                                trailing: Text(_formatIDR(t['jumlah']),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: t['tipe'] == 'PEMASUKAN'
                                            ? Colors.green
                                            : Colors.red)),
                              ))
                          .toList(),
                    ),

              const SizedBox(height: 25),

              // 4. GOAL SLIDER (Tabungan)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Target Tabungan",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => widget.onNavigateToTab(3),
                    child: const Text("Lihat Semua",
                        style: TextStyle(color: Colors.teal)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: _listTabungan.isEmpty
                    ? _buildEmptyState("Belum ada target")
                    : PageView.builder(
                        controller: PageController(viewportFraction: 0.9),
                        itemCount: _listTabungan.length,
                        itemBuilder: (context, index) {
                          final goal = _listTabungan[index];
                          double progress = goal.jumlah / goal.targetJumlah;
                          if (goal.targetJumlah == 0) progress = 1;

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(goal.nama,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    value: progress > 1 ? 1 : progress,
                                    backgroundColor: Colors.grey[200],
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                      "${(progress * 100).toStringAsFixed(1)}% Terkumpul",
                                      style: const TextStyle(fontSize: 12)),
                                  const Spacer(),
                                  Text(
                                      "${_formatIDR(goal.jumlah)} / ${_formatIDR(goal.targetJumlah)}",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showChatAI,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text("Chat AI"),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontSize: 12)),
            const SizedBox(height: 4),
            FittedBox(
                child: Text(_formatIDR(amount),
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Text(msg, style: const TextStyle(color: Colors.grey)));
  }
}
