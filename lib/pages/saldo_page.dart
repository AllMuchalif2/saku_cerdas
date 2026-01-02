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

  // 🔔 NOTIF TENGAH LAYAR
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
          backgroundColor: Colors.teal,
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                showCenterNotif("Nama saldo tidak boleh kosong",
                    success: false);
                return;
              }

              await SaldoService.insertSaldo(
                Saldo(nama: controller.text.trim(), total: 0),
              );

              Navigator.pop(context);
              loadSaldo();
              showCenterNotif("Saldo telah berhasil ditambahkan");
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
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                showCenterNotif("Nama saldo tidak boleh kosong",
                    success: false);
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
              showCenterNotif("Saldo telah berhasil diubah");
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // 💸 ISI SALDO
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              final nominal = int.tryParse(controller.text) ?? 0;
              if (nominal <= 0) {
                showCenterNotif("Nominal tidak valid", success: false);
                return;
              }

              await SaldoService.topUpSaldo(
                saldoId: saldo.saldoId!,
                nominal: nominal,
              );

              Navigator.pop(context);
              loadSaldo();
              showCenterNotif("Saldo telah berhasil diisi");
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
    showCenterNotif("Saldo telah berhasil dihapus");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text("Dompet"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
