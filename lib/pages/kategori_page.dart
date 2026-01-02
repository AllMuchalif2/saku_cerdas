import 'package:flutter/material.dart';
import '../models/kategori.dart';
import '../services/kategori_service.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({Key? key}) : super(key: key);

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String nama = _namaController.text.trim();
    final bool isEdit = kategori != null;

    try {
      if (!isEdit) {
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
      Navigator.of(context).pop(); // Pop form dialog
      _refreshCategories();

      // Show success dialog
      showDialog(
        context: this.context, // Use page's context
        builder: (ctx) => AlertDialog(
          title: const Text('Berhasil'),
          content: Text(isEdit
              ? 'Kategori berhasil diubah.'
              : 'Kategori berhasil ditambahkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Kesalahan umum (misal: masalah koneksi db)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
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
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            isEdit ? 'Edit Kategori' : 'Tambah Kategori',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _namaController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Nama Kategori',
                          labelStyle: TextStyle(color: Colors.black54),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                        autofocus: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama kategori tidak boleh kosong';
                          }
                          final trimmedValue = value.trim();

                          final isDuplicate = _categories.any(
                            (cat) =>
                                cat.nama.toLowerCase() ==
                                trimmedValue.toLowerCase(),
                          );

                          if (isEdit) {
                            if (kategori.nama.toLowerCase() !=
                                    trimmedValue.toLowerCase() &&
                                isDuplicate) {
                              return 'Nama kategori sudah ada.';
                            }
                          } else {
                            if (isDuplicate) {
                              return 'Nama kategori sudah ada.';
                            }
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTipe,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Tipe Transaksi',
                          labelStyle: TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
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
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
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
            "Anda yakin ingin menghapus '${kategori.nama}'? Ini tidak akan menghapus data transaksi yang sudah ada."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await KategoriService.softDeleteKategori(kategori.kategoriId!);
              if (!mounted) return;
              Navigator.pop(ctx); // Pop confirm dialog
              _refreshCategories();

              // Show success dialog
              showDialog(
                context: this.context, // Use page's context
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Berhasil'),
                  content: const Text('Kategori berhasil dihapus.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
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
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCategories,
        child: _isLoading
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
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)), // Warna teks hitam
                          subtitle: Text(cat.tipe,
                              style: const TextStyle(
                                  color: Colors.black54)), // Warna teks hitam
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showFormDialog(kategori: cat);
                              } else if (value == 'delete') {
                                _showDeleteDialog(cat);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text("Edit")
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text("Hapus")
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
