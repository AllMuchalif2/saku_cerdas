import 'package:flutter/material.dart';
import '../models/saldo.dart';
import '../services/saldo_service.dart';

class SaldoPage extends StatefulWidget {
  const SaldoPage({super.key});

  @override
  State<SaldoPage> createState() => _SaldoPageState();
}

class _SaldoPageState extends State<SaldoPage> {
  List<Saldo> listSaldo = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSaldo();
  }

  Future<void> loadSaldo() async {
    final data = await SaldoService.getAllSaldo();
    setState(() {
      listSaldo = data;
      loading = false;
    });
  }

  // 🔔 NOTIF
  void showNotif(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ➕ TAMBAH SALDO
  void tambahSaldo() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Saldo"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nama Saldo"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                showNotif("Nama saldo tidak boleh kosong");
                return;
              }

              await SaldoService.insertSaldo(
                Saldo(nama: controller.text.trim(), total: 0),
              );

              Navigator.pop(context);
              loadSaldo();
              showNotif("Saldo baru berhasil ditambahkan");
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ✏️ EDIT SALDO
  void editSaldo(Saldo saldo) async {
    final controller = TextEditingController(text: saldo.nama);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Edit Nama Saldo"),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                showNotif("Nama saldo tidak boleh kosong");
                return;
              }

              await SaldoService.updateSaldo(
                Saldo(
                  saldoId: saldo.saldoId,
                  nama: controller.text.trim(),
                  total: saldo.total,
                ),
              );

              Navigator.pop(context);
              loadSaldo();
              showNotif("Saldo berhasil diedit");
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // 💸 ISI SALDO (DIALOG)
  void isiSaldoDialog(Saldo saldo) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Isi ${saldo.nama}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Nominal Top Up",
            prefixText: "Rp ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final nominal = int.tryParse(controller.text) ?? 0;
              if (nominal <= 0) {
                showNotif("Nominal tidak valid");
                return;
              }

              await SaldoService.topUpSaldo(
                saldoId: saldo.saldoId!,
                nominal: nominal,
              );

              Navigator.pop(context);
              loadSaldo();
              showNotif("Saldo berhasil diisi");
            },
            child: const Text("Isi Saldo"),
          ),
        ],
      ),
    );
  }

  // 🗑️ HAPUS SALDO
  void hapusSaldo(int id) async {
    await SaldoService.deleteSaldo(id);
    loadSaldo();
    showNotif("Saldo berhasil dihapus");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dompet"),
      ),

      // ➕ FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, size: 30),
        onPressed: tambahSaldo,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : listSaldo.isEmpty
              ? const Center(child: Text("Belum ada saldo"))
              : ListView.builder(
                  itemCount: listSaldo.length,
                  itemBuilder: (_, i) {
                    final s = listSaldo[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          s.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Rp ${s.total}"),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'isi') {
                              isiSaldoDialog(s);
                            } else if (value == 'edit') {
                              editSaldo(s);
                            } else if (value == 'hapus') {
                              hapusSaldo(s.saldoId!);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'isi',
                              child: Text("Isi Saldo"),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Text("Edit Nama"),
                            ),
                            PopupMenuItem(
                              value: 'hapus',
                              child: Text("Hapus"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
