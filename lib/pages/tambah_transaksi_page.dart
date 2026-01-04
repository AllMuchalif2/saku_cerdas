import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Diperlukan untuk NumberFormat
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
  final Map<String, dynamic>? initialData; // Data dari AI
  const TambahTransaksiPage({super.key, this.onSaveSuccess, this.initialData});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

// FORMATTER CUSTOM UNTUK RUPIAH
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;

    // Ambil angka saja
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');

    double value = double.parse(cleanText);
    final formatter =
        NumberFormat.decimalPattern('id'); // Format Indonesia (titik)
    String newText = formatter.format(value);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
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
    _loadAllData();
  }

  // 🔔 FUNGSI NOTIFIKASI CUSTOM
  void showCenterNotif(String pesan, {bool success = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return AlertDialog(
          backgroundColor: success ? Colors.teal : Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pesan,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

        // --- LOGIKA PRE-FILL DARI AI ---
        if (widget.initialData != null) {
          final data = widget.initialData!;

          // 1. Nama
          _namaController.text = data['nama'] ?? '';

          // 2. Nominal (Format ke tampilan Rupiah: 15000 -> 15.000)
          if (data['jumlah'] != null) {
            double val = (data['jumlah'] as num).toDouble();
            _nominalController.text =
                NumberFormat.decimalPattern('id').format(val);
          }

          // 3. ID Selection (Pastikan ID ada di list yang baru di-load)
          _selectedKategoriId = data['kategori_id'];
          _selectedSaldoId = data['saldo_id'];
          _selectedTabunganId = data['tabungan_id'];

          // 4. Tanggal
          if (data['tanggal'] != null) {
            _tanggalController.text = data['tanggal'];
          } else {
            _tanggalController.text = DateTime.now().toString().split(' ')[0];
          }
        } else {
          _tanggalController.text = DateTime.now().toString().split(' ')[0];
        }
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _simpanTransaksi() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedKategoriId == null || _selectedSaldoId == null) {
        showCenterNotif("Kategori dan Saldo wajib dipilih!", success: false);
        return;
      }

      // MODIFIKASI: Hilangkan titik sebelum parse ke double
      final String cleanNominal = _nominalController.text.replaceAll('.', '');
      final nominalInput = double.tryParse(cleanNominal) ?? 0.0;

      final kategoriTerpilih =
          _kategoriList.firstWhere((k) => k.kategoriId == _selectedKategoriId);
      final saldoTerpilih =
          _saldoList.firstWhere((s) => s.saldoId == _selectedSaldoId);

      if (kategoriTerpilih.tipe.toLowerCase() == 'pengeluaran' ||
          kategoriTerpilih.tipe.toLowerCase() == 'keluar') {
        if (nominalInput > saldoTerpilih.total) {
          showCenterNotif("Saldo '${saldoTerpilih.nama}' tidak cukup!",
              success: false);
          return;
        }
      }

      if (mounted) setState(() => _isSubmitting = true);

      try {
        Transaksi transaksiBaru = Transaksi(
          saldoId: _selectedSaldoId!,
          kategoriId: _selectedKategoriId!,
          tabunganId: _selectedTabunganId,
          jumlah: nominalInput,
          tanggal: _tanggalController.text,
          nama: _namaController.text,
        );

        await TransaksiService.insertTransaksi(transaksiBaru);

        if (mounted) {
          setState(() => _isSubmitting = false);

          showCenterNotif("Transaksi Berhasil Disimpan");

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              widget.onSaveSuccess?.call();
              Navigator.pop(context, true);
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          showCenterNotif("Gagal menyimpan data", success: false);
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
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CurrencyInputFormatter(), // TAMBAHKAN FORMATTER DI SINI
                            ],
                            decoration: const InputDecoration(
                              labelText: "Nominal Transaksi",
                              prefixText: "Rp ",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan nominal';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedSaldoId,
                            decoration: const InputDecoration(
                              labelText: 'Jenis Saldo',
                              border: OutlineInputBorder(),
                            ),
                            items: _saldoList.map((s) {
                              return DropdownMenuItem<int>(
                                value: s.saldoId,
                                child: Text(
                                    "${s.nama} (Tersedia: Rp ${NumberFormat.decimalPattern('id').format(s.total)})"),
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
                              suffixIcon: Icon(Icons.calendar_today),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('SUBMIT TRANSAKSI',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
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
}
