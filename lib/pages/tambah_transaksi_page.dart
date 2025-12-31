import 'package:flutter/material.dart';
import '../services/transaksi_service.dart';
import '../services/kategori_service.dart';
import '../services/saldo_service.dart';
import '../services/tabungan_service.dart';
import '../models/transaksi.dart';
import '../models/kategori.dart';
import '../models/saldo.dart';
import '../models/tabungan.dart';

class TambahTransaksiPage extends StatefulWidget {
  final VoidCallback? onSaveSuccess;
  const TambahTransaksiPage({super.key, this.onSaveSuccess});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  List<KategoriModel> _kategoriList = [];
  List<Saldo> _saldoList = [];
  List<Tabungan> _tabunganList = [];

  int? _selectedKategoriId;
  int? _selectedSaldoId;
  int? _selectedTabunganId;

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tanggalController.text = DateTime.now().toString().split(' ')[0];
    _loadAllData();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _nominalController.clear();
    _tanggalController.text = DateTime.now().toString().split(' ')[0];
    setState(() {
      _selectedKategoriId = null;
      _selectedSaldoId = null;
      _selectedTabunganId = null;
    });
  }

  Future<void> _loadAllData() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      final results = await Future.wait([
        KategoriService.getAllKategori(),
        SaldoService.getAllSaldo(),
        TabunganService.getAllTabungan(),
      ]);

      if (!mounted) return;

      setState(() {
        _kategoriList = results[0] as List<KategoriModel>;
        _saldoList = results[1] as List<Saldo>;
        _tabunganList = results[2] as List<Tabungan>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // FUNGSI SIMPAN YANG SUDAH DIPERBAIKI
  void _simpanTransaksi() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedKategoriId == null || _selectedSaldoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Kategori dan Jenis Saldo wajib dipilih!')),
        );
        return;
      }

      if (mounted) setState(() => _isSubmitting = true);

      try {
        Transaksi transaksiBaru = Transaksi(
          saldoId: _selectedSaldoId!,
          kategoriId: _selectedKategoriId!,
          tabunganId: _selectedTabunganId,
          jumlah: double.tryParse(_nominalController.text) ?? 0.0,
          tanggal: _tanggalController.text,
          nama: _namaController.text, // Make sure to add this
        );

        await TransaksiService.insertTransaksi(transaksiBaru);

        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi Berhasil Disimpan')),
          );
          _resetForm(); // Reset form for next entry
          widget.onSaveSuccess?.call(); // Panggil callback jika ada
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Gagal Simpan"),
              content: Text("Terjadi kesalahan database: $e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Tambah Transaksi'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAllData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _namaController,
                            decoration: const InputDecoration(
                              labelText: 'Keterangan Transaksi',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.edit),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Masukkan keterangan'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedKategoriId,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _kategoriList.map((kat) {
                              return DropdownMenuItem<int>(
                                value: kat.kategoriId,
                                child: Text("${kat.nama} (${kat.tipe})"),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedKategoriId = val),
                            validator: (val) =>
                                val == null ? 'Pilih kategori' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nominalController,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah (Rp)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Masukkan nominal'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedSaldoId,
                            decoration: const InputDecoration(
                              labelText: 'Jenis Saldo',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.account_balance_wallet),
                            ),
                            items: _saldoList.map((s) {
                              return DropdownMenuItem<int>(
                                value: s.saldoId,
                                child: Text(s.nama),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedSaldoId = val),
                            validator: (val) =>
                                val == null ? 'Pilih jenis saldo' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int?>(
                            value: _selectedTabunganId,
                            decoration: const InputDecoration(
                              labelText: 'Pilih Tabungan (Opsional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.savings),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text("Tanpa Tabungan"),
                              ),
                              ..._tabunganList.map((t) {
                                return DropdownMenuItem<int?>(
                                  value: t.tabunganId,
                                  child: Text(t.nama),
                                );
                              }),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedTabunganId = val),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _tanggalController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Tanggal',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _tanggalController.text =
                                      pickedDate.toString().split(' ')[0];
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _simpanTransaksi,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('SUBMIT TRANSAKSI',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ), // Column
                    ), // Form
                  ), // SingleChildScrollView
                ), // Scaffold
        ),

        // In-widget modal overlay shown while submitting
        if (_isSubmitting)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }
}
