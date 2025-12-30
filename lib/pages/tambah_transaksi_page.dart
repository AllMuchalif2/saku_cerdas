import 'package:flutter/material.dart';
import '../services/transaksi_services.dart'; // Pastikan nama file sesuai (pakai 's' atau tidak)
import '../models/transaksi.dart';

class TambahTransaksiPage extends StatefulWidget {
  const TambahTransaksiPage({super.key});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input teks (Sesuai Mockup)
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  // Variabel untuk menampung ID (Foreign Keys)
  int? _kategoriId = 1; // Default kategori
  int _saldoId = 1; // Default jenis saldo
  int? _tabunganId; // Opsional

  @override
  void initState() {
    super.initState();
    _tanggalController.text = DateTime.now().toString().split(' ')[0];
  }

  void _simpanTransaksi() async {
    if (_formKey.currentState!.validate()) {
      // 1. Membuat objek sesuai Model yang Anda miliki
      Transaksi transaksiBaru = Transaksi(
        saldoId: _saldoId,
        kategoriId: _kategoriId ?? 1,
        tabunganId: _tabunganId,
        jumlah: double.tryParse(_jumlahController.text) ?? 0.0,
        tanggal: _tanggalController.text,
      );

      // 2. Memanggil Service
      await TransaksiService.insertTransaksi(transaksiBaru);

      // 3. Perbaikan Async Gaps (Mounted Check)
      if (!mounted) return;

      // 4. Kembali ke halaman sebelumnya
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
            children: [
              // Field Nama Transaksi
              _buildTextField(_namaController, 'Nama Transaksi', Icons.edit),

              // Field Kategori (Dropdown/Input)
              _buildFakeField('Kategori', Icons.category, onTap: () {
                // Logika pilih kategori
              }),

              // Field Jumlah (Field 'jumlah' di model Anda)
              _buildTextField(_jumlahController, 'Jumlah', Icons.money,
                  isNumber: true),

              // Field Jenis Saldo
              _buildFakeField('Jenis Saldo', Icons.account_balance_wallet,
                  onTap: () {
                // Logika pilih saldo
              }),

              // Field Tabungan
              _buildFakeField('Tabungan', Icons.savings, onTap: () {
                // Logika pilih tabungan
              }),

              // Field Tanggal
              _buildTextField(
                  _tanggalController, 'Tanggal', Icons.calendar_today,
                  readOnly: true, onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() => _tanggalController.text =
                      picked.toString().split(' ')[0]);
                }
              }),

              const SizedBox(height: 30),

              // Tombol Submit (Sesuai Mockup)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _simpanTransaksi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.grey[300], // Warna sesuai mockup abu-abu
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero), // Kotak sesuai mockup
                  ),
                  child: const Text('SUBMIT',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk membuat input field sesuai desain kotak abu-abu di gambar
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, bool readOnly = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[300],
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: label.toLowerCase(),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
        validator: (val) =>
            val == null || val.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }

  // Helper untuk field yang bertindak seperti tombol (kategori/saldo/tabungan)
  Widget _buildFakeField(String label, IconData icon,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(20),
        color: Colors.grey[300],
        child:
            Text(label.toLowerCase(), style: TextStyle(color: Colors.black54)),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }
}
