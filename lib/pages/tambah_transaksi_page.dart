import 'package:flutter/material.dart';
import '../services/transaksi_services.dart'; // Sesuaikan jika nama filenya transaksi_service.dart
import '../models/transaksi.dart';

class TambahTransaksiPage extends StatefulWidget {
  const TambahTransaksiPage({super.key});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input teks
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  // Variabel untuk menampung input sesuai Model Transaksi
  int? _kategoriId = 1; // Default ID Kategori (misal: Umum)
  int _saldoId = 1; // Default ID Saldo (misal: Kas Utama)
  int? _tabunganId;
  String _tipeTerpilih = 'PENGELUARAN';

  @override
  void initState() {
    super.initState();
    // Set default tanggal hari ini
    _tanggalController.text = DateTime.now().toString().split(' ')[0];
  }

  void _simpanTransaksi() async {
    if (_formKey.currentState!.validate()) {
      // Membuat objek Transaksi menggunakan variabel yang ada di model Anda
      Transaksi transaksiBaru = Transaksi(
        saldoId: _saldoId,
        kategoriId: _kategoriId ?? 1,
        tabunganId: _tabunganId,
        jumlah: double.tryParse(_nominalController.text) ?? 0.0,
        tanggal: _tanggalController.text,
      );

      // Memanggil fungsi insert di TransaksiService
      await TransaksiService.insertTransaksi(transaksiBaru);

      if (!mounted) return;

      // Kembali ke halaman sebelumnya dan menyegarkan data
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi Berhasil Disimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pilihan Tipe
              DropdownButtonFormField<String>(
                value: _tipeTerpilih,
                decoration: const InputDecoration(
                  labelText: 'Tipe Transaksi',
                  border: OutlineInputBorder(),
                ),
                items: ['PENGELUARAN', 'PEMASUKAN'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _tipeTerpilih = val!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Input Nominal (Jumlah)
              TextFormField(
                controller: _nominalController,
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Masukkan nominal' : null,
              ),
              const SizedBox(height: 16),

              // Input Tanggal
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Transaksi',
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
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _simpanTransaksi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'SIMPAN',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }
}
