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
  const TambahTransaksiPage({super.key});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final _formKey = GlobalKey<FormState>();

  // Services provide static methods; call them via the class

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

  Future<void> _loadAllData() async {
    try {
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

      // 1. Tampilkan in-widget loading (lebih aman daripada showDialog)
      if (mounted) setState(() => _isSubmitting = true);

      try {
        debugPrint('Mulai submit transaksi...');
        Transaksi transaksiBaru = Transaksi(
          saldoId: _selectedSaldoId!,
          kategoriId: _selectedKategoriId!,
          tabunganId: _selectedTabunganId,
          jumlah: double.tryParse(_nominalController.text) ?? 0.0,
          tanggal: _tanggalController.text,
        );

        // 2. Eksekusi ke Service
        final int insertedId =
            await TransaksiService.insertTransaksi(transaksiBaru);
        debugPrint('insertTransaksi berhasil, id: $insertedId');

        // 2. Success: clear submitting flag and return to caller
        if (mounted) {
          setState(() => _isSubmitting = false);
          // Small delay to allow UI to settle and avoid race conditions
          await Future.delayed(const Duration(milliseconds: 150));

          // Safety: only pop if navigator can pop to avoid popping root or
          // causing an empty history (which led to _history.isNotEmpty assert).
          final navigator = Navigator.of(context);
          final canPop = navigator.canPop();
          debugPrint('About to pop TambahTransaksiPage, canPop=$canPop');
          if (canPop) {
            try {
              navigator.pop(true);
            } catch (e) {
              debugPrint('Error while popping: $e');
            }
          } else {
            debugPrint(
                'Navigator cannot pop — skipping pop to avoid empty history.');
            // Beri notifikasi sukses di halaman ini jika kita tidak bisa kembali
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi Berhasil Disimpan')),
            );
          }
        }
      } catch (e, s) {
        // JIKA ERROR: Tutup loading dan tampilkan pesan error (Mencegah Layar Hitam)
        debugPrint("EROR SAAT SIMPAN: $e");
        debugPrint('$s');

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
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                          validator: (value) => value == null || value.isEmpty
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
                          validator: (value) => value == null || value.isEmpty
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
                          onPressed: _simpanTransaksi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
