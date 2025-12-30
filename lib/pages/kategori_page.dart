import 'package:flutter/material.dart';
import '../models/kategori.dart';
import '../services/kategori_services.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({Key? key}) : super(key: key);

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final KategoriService _kategoriService = KategoriService();
  List<KategoriModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  // Mengambil ulang data kategori dari database
  Future<void> _refreshCategories() async {
    setState(() => _isLoading = true);
    final data = await _kategoriService.getAllKategori();
    setState(() {
      _categories = data;
      _isLoading = false;
    });
  }

  // Menampilkan Bottom Sheet untuk Tambah/Edit
  void _showForm(KategoriModel? kategori) {
    final TextEditingController _namaController = TextEditingController();
    String _selectedTipe = 'PENGELUARAN';

    if (kategori != null) {
      _namaController.text = kategori.nama;
      _selectedTipe = kategori.tipe;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kategori == null ? "Tambah Kategori" : "Ubah Kategori",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedTipe,
              decoration: const InputDecoration(
                labelText: 'Tipe Transaksi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'PEMASUKAN', child: Text('PEMASUKAN')),
                DropdownMenuItem(
                    value: 'PENGELUARAN', child: Text('PENGELUARAN')),
              ],
              onChanged: (val) => _selectedTipe = val!,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4300FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async {
                  if (_namaController.text.isEmpty) return;

                  if (kategori == null) {
                    await _kategoriService.addKategori(
                      KategoriModel(
                          nama: _namaController.text, tipe: _selectedTipe),
                    );
                  } else {
                    await _kategoriService.updateKategori(
                      KategoriModel(
                        kategoriId: kategori.kategoriId,
                        nama: _namaController.text,
                        tipe: _selectedTipe,
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                  _refreshCategories();
                },
                child: Text(kategori == null ? 'SIMPAN' : 'UPDATE'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Fungsi hapus dengan konfirmasi
  void _deleteCategory(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Kategori?"),
        content: const Text(
            "Transaksi dengan kategori ini mungkin akan terpengaruh."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL")),
          TextButton(
            onPressed: () async {
              await _kategoriService.deleteKategori(id);
              Navigator.pop(context);
              _refreshCategories();
            },
            child: const Text("HAPUS", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Kategori"),
        actions: [
          IconButton(
              onPressed: _refreshCategories, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text("Belum ada kategori."))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isPemasukan = cat.tipe == 'PEMASUKAN';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPemasukan
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          child: Icon(
                            isPemasukan
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isPemasukan ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(cat.nama,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(cat.tipe),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFF0065F8)),
                              onPressed: () => _showForm(cat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(cat.kategoriId!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4300FF),
        foregroundColor: Colors.white,
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
