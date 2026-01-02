import 'package:flutter/material.dart';
import '../models/saldo.dart';
import '../services/saldo_service.dart';

class IsiSaldoPage extends StatefulWidget {
  final Saldo saldo;
  const IsiSaldoPage({super.key, required this.saldo});

  @override
  State<IsiSaldoPage> createState() => _IsiSaldoPageState();
}

class _IsiSaldoPageState extends State<IsiSaldoPage> {
  final _controller = TextEditingController();

  void isiSaldo() async {
    final nominal = int.tryParse(_controller.text) ?? 0;
    if (nominal <= 0) return;

    await SaldoService.topUpSaldo(
      saldoId: widget.saldo.saldoId!,
      nominal: nominal,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Isi ${widget.saldo.nama}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nominal Top Up",
                prefixText: "Rp ",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isiSaldo,
              child: const Text("Isi Saldo"),
            )
          ],
        ),
      ),
    );
  }
}
