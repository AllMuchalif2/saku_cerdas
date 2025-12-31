import 'package:flutter/material.dart';
import 'package:saku_cerdas/models/kategori.dart';
import 'package:saku_cerdas/services/kategori_service.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({Key? key}) : super(key: key);

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final TextEditingController _namaController = TextEditingController();
  String _selectedTipe = 'PENGELUARAN';

  List<KategoriModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  Future<void> _refreshCategories() async {
    setState(() => _isLoading = true);
    final data = await KategoriService.getAllKategori();
    setState(() {
      _categories = data;
      _isLoading = false;
    });
  }

  Future<void> _simpanKategori({KategoriModel? kategori}) async {
    final String nama = _namaController.text;
    if (nama.isEmpty) return;

    if (kategori == null) {
      // Tambah baru
      await KategoriService.addKategori(
        KategoriModel(nama: nama, tipe: _selectedTipe),
      );
    } else {
      // Update
      await KategoriService.updateKategori(
        KategoriModel(
          kategoriId: kategori.kategoriId,
          nama: nama,
          tipe: _selectedTipe,
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // Tutup dialog
    _refreshCategories(); // Refresh list
  }

  void _showFormDialog({KategoriModel? kategori}) {
    bool isEdit = kategori != null;

    if (isEdit) {
      _namaController.text = kategori.nama;
      _selectedTipe = kategori.tipe;
    } else {
      _namaController.clear();
      _selectedTipe = 'PENGELUARAN';
    }

    showDialog(
      context: context,
      builder: (context) {
        // Gunakan StatefulBuilder agar Dropdown bisa update state di dalam dialog
        return AlertDialog(
          title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Kategori'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTipe,
                      decoration: const InputDecoration(
                        labelText: 'Tipe Transaksi',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'PENGELUARAN', child: Text('PENGELUARAN')),
                        DropdownMenuItem(
                            value: 'PEMASUKAN', child: Text('PEMASUKAN')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedTipe = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Sesuai permintaan
                foregroundColor: Colors.teal, // Agar teks terlihat
                side: const BorderSide(color: Colors.teal), // Border agar tombol terlihat
              ),
              onPressed: () => _simpanKategori(kategori: kategori),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(KategoriModel kategori) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Kategori?"),
        content: Text(
            "Anda yakin ingin menghapus '${kategori.nama}'? Transaksi dengan kategori ini tidak akan terhapus namun mungkin akan kehilangan relasinya."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await KategoriService.deleteKategori(kategori.kategoriId!);
              if (!mounted) return;
              Navigator.pop(ctx);
              _refreshCategories();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
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
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: _refreshCategories, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text("Belum ada kategori."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isPemasukan = cat.tipe == 'PEMASUKAN';

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFormDialog(kategori: cat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(cat),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}