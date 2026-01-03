import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaksi_service.dart';
import '../db_helper.dart';
import './tambah_transaksi_page.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  // Variabel penampung filter
  String _selectedFilter = 'SEMUA';
  String _selectedTimeFilter = 'SEMUA'; // Tambahan filter waktu

  String formatRupiah(num nominal) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(nominal);
  }

  Future<void> _handleRefresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _refreshData() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: false,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- BARIS FILTER KATEGORI ---
          Container(
            padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('SEMUA'),
                _buildFilterButton('PEMASUKAN'),
                _buildFilterButton('PENGELUARAN'),
              ],
            ),
          ),

          // --- BARIS FILTER WAKTU ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTimeFilterChip('SEMUA'),
                  const SizedBox(width: 8),
                  _buildTimeFilterChip('HARI INI'),
                  const SizedBox(width: 8),
                  _buildTimeFilterChip('BULAN INI'),
                  const SizedBox(width: 8),
                  _buildTimeFilterChip('TAHUN INI'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // --- DAFTAR TRANSAKSI ---
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: Colors.teal,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: TransaksiService.getAllTransaksi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  }

                  // Logika Filter Data
                  List<Map<String, dynamic>> listTransaksi =
                      snapshot.data ?? [];
                  DateTime now = DateTime.now();

                  // 1. Filter Tipe
                  if (_selectedFilter != 'SEMUA') {
                    listTransaksi = listTransaksi
                        .where((item) =>
                            item['tipe']?.toString().toUpperCase() ==
                            _selectedFilter)
                        .toList();
                  }

                  // 2. Filter Waktu
                  if (_selectedTimeFilter != 'SEMUA') {
                    listTransaksi = listTransaksi.where((item) {
                      try {
                        DateTime tgl = DateTime.parse(item['tanggal']);
                        if (_selectedTimeFilter == 'HARI INI') {
                          return tgl.year == now.year &&
                              tgl.month == now.month &&
                              tgl.day == now.day;
                        } else if (_selectedTimeFilter == 'BULAN INI') {
                          return tgl.year == now.year && tgl.month == now.month;
                        } else if (_selectedTimeFilter == 'TAHUN INI') {
                          return tgl.year == now.year;
                        }
                      } catch (e) {
                        return true;
                      }
                      return true;
                    }).toList();
                  }

                  // --- LOGIKA SUMMARY CARD ---
                  double totalPemasukan = 0;
                  double totalPengeluaran = 0;
                  for (var item in listTransaksi) {
                    double jml = (item['jumlah'] as num).toDouble();
                    if (item['tipe']?.toString().toUpperCase() == 'PEMASUKAN') {
                      totalPemasukan += jml;
                    } else {
                      totalPengeluaran += jml;
                    }
                  }

                  return Column(
                    children: [
                      // Widget Summary Card yang ditambahkan
                      _buildSummaryCard(totalPemasukan, totalPengeluaran),

                      Expanded(
                        child: listTransaksi.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 100),
                                  Center(child: Text('Tidak ada transaksi.')),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                itemCount: listTransaksi.length,
                                itemBuilder: (context, index) {
                                  final item = listTransaksi[index];
                                  final bool isPemasukan =
                                      item['tipe']?.toString().toUpperCase() ==
                                          'PEMASUKAN';

                                  return Card(
                                    elevation: 2,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isPemasukan
                                            ? Colors.green[100]
                                            : Colors.red[100],
                                        child: Icon(
                                          isPemasukan
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: isPemasukan
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      title: Text(item['nama'] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          "${item['nama_kategori']} • ${item['tanggal']}"),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            (isPemasukan ? "+ " : "- ") +
                                                formatRupiah(item['jumlah']),
                                            style: TextStyle(
                                                color: isPemasukan
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (String value) {
                                              if (value == 'detail') {
                                                _showDetailTransaksi(item);
                                              } else if (value == 'edit') {
                                                _showEditDialog(item);
                                              } else if (value == 'hapus') {
                                                _konfirmasiHapus(
                                                    item['transaksi_id']);
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) => [
                                              const PopupMenuItem(
                                                value: 'detail',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.info_outline,
                                                        size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Detail'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit,
                                                        color: Colors.orange,
                                                        size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'hapus',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        color: Colors.red,
                                                        size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Hapus'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Summary Card
  Widget _buildSummaryCard(double income, double expense) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade700,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pemasukan",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(formatRupiah(income),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
          ),
          Container(height: 30, width: 1, color: Colors.white24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Pengeluaran",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(formatRupiah(expense),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk tombol filter kategori
  Widget _buildFilterButton(String label) {
    bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk chip filter waktu
  Widget _buildTimeFilterChip(String label) {
    bool isActive = _selectedTimeFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (bool selected) {
        setState(() {
          _selectedTimeFilter = label;
        });
      },
      selectedColor: Colors.teal.withOpacity(0.2),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isActive ? Colors.teal : Colors.black87,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isActive ? Colors.teal : Colors.transparent),
      ),
    );
  }

  // --- FUNGSI EDIT, DETAIL, DAN HAPUS ---
  void _showEditDialog(Map<String, dynamic> item) async {
    final db = await DBHelper.db();

    List<Map<String, dynamic>> categories = await db.query('kategori');
    List<Map<String, dynamic>> balances = await db.query('saldo');
    List<Map<String, dynamic>> savings = await db.query('tabungan');

    final TextEditingController namaController =
        TextEditingController(text: item['nama']);
    final TextEditingController jumlahController =
        TextEditingController(text: item['jumlah'].toString());

    int? selectedKatId = item['kategori_id'];
    int? selectedSaldoId = item['saldo_id'];
    int? selectedTabId = item['tabungan_id'];
    String selectedDate = item['tanggal'];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Transaksi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration:
                          const InputDecoration(labelText: 'Keterangan'),
                    ),
                    TextField(
                      controller: jumlahController,
                      decoration: const InputDecoration(labelText: 'Nominal'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: selectedKatId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat['kategori_id'],
                          child: Text("${cat['nama']} (${cat['tipe']})"),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedKatId = val),
                    ),
                    DropdownButtonFormField<int>(
                      value: selectedSaldoId,
                      decoration:
                          const InputDecoration(labelText: 'Sumber Saldo'),
                      items: balances.map((s) {
                        return DropdownMenuItem<int>(
                          value: s['saldo_id'],
                          child: Text(s['nama']),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedSaldoId = val),
                    ),
                    DropdownButtonFormField<int?>(
                      value: selectedTabId,
                      decoration: const InputDecoration(
                          labelText: 'Pilih Tabungan (Opsional)'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text("-- Tanpa Tabungan --"),
                        ),
                        ...savings.map((t) {
                          return DropdownMenuItem<int?>(
                            value: t['tabungan_id'],
                            child: Text(t['nama']),
                          );
                        }),
                      ],
                      onChanged: (val) =>
                          setDialogState(() => selectedTabId = val),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(selectedDate),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(selectedDate),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate =
                              DateFormat('yyyy-MM-dd').format(picked));
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await TransaksiService.updateTransaksiLengkap(
                        id: item['transaksi_id'],
                        nama: namaController.text,
                        jumlah: double.parse(jumlahController.text),
                        kategoriId: selectedKatId!,
                        saldoId: selectedSaldoId!,
                        tabunganId: selectedTabId,
                        tanggal: selectedDate,
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                      _refreshData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal Update: $e')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text('Simpan',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailTransaksi(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Detail Transaksi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            _detailRow("Keterangan", item['nama']),
            _detailRow("Nominal", formatRupiah(item['jumlah'])),
            _detailRow("Kategori", item['nama_kategori']),
            _detailRow("Tipe", item['tipe']),
            _detailRow("Tanggal", item['tanggal']),
            _detailRow("Sumber Saldo", item['nama_saldo']),
            _detailRow("Tabungan", item['nama_tabungan'] ?? "Tidak Ada"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 45)),
              child: const Text("Tutup", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _konfirmasiHapus(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text('Saldo akan dikembalikan secara otomatis.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await TransaksiService.deleteTransaksi(id);
              if (!mounted) return;
              Navigator.pop(context);
              _refreshData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
