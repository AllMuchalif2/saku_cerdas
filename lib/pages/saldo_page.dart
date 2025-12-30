import 'package:flutter/material.dart';
import 'package:saku_cerdas/models/saldo.dart';
import 'package:saku_cerdas/services/saldo_service.dart';

class SaldoPage extends StatefulWidget {
  const SaldoPage({super.key});

  @override
  State<SaldoPage> createState() => _SaldoPageState();
}

class _SaldoPageState extends State<SaldoPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _totalController = TextEditingController();

  final SaldoService _service = SaldoService();

  void simpan() async {
    if (_formKey.currentState!.validate()) {
      final saldo = Saldo(
        nama: _namaController.text,
        total: int.parse(_totalController.text),
      );

      await _service.insertSaldo(saldo);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Saldo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Saldo'),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _totalController,
                decoration: const InputDecoration(labelText: 'Total'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.isEmpty ? 'Total tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: simpan,
                child: const Text('Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
