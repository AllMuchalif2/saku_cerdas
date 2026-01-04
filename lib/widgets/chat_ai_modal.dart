import 'package:flutter/material.dart';
import '../services/groq_service.dart';
import '../services/kategori_service.dart';
import '../services/saldo_service.dart';
import '../services/tabungan_service.dart';
import '../models/kategori.dart';
import '../models/saldo.dart';
import '../models/tabungan.dart';

class ChatAIModal extends StatefulWidget {
  const ChatAIModal({super.key});

  @override
  State<ChatAIModal> createState() => _ChatAIModalState();
}

class _ChatAIModalState extends State<ChatAIModal> {
  final TextEditingController _messageController = TextEditingController();
  bool _isProcessing = false;

  void showCenterNotif(String pesan, {bool success = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        });

        return AlertDialog(
          backgroundColor: success ? Colors.teal : Colors.red,
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

  Future<void> _processChat() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Load Data
      final results = await Future.wait([
        KategoriService.getAllKategori(),
        SaldoService.getAllSaldo(),
        TabunganService.getAllTabungan(),
      ]);

      final kategoriList = results[0] as List<KategoriModel>;
      final saldoList = results[1] as List<Saldo>;
      final tabunganList = results[2] as List<Tabungan>;

      // Panggil AI Service
      final result = await GroqService.extractTransaction(
        message: message,
        kategoriList: kategoriList,
        saldoList: saldoList,
        tabunganList: tabunganList,
      );

      if (!mounted) return;

      if (result != null) {
        // Jika sukses, tutup modal dan kembalikan data
        Navigator.pop(context, result);
      } else {
        showCenterNotif('Gagal memproses pesan. Coba lagi.', success: false);
      }
    } catch (e) {
      if (mounted) {
        showCenterNotif('Error: $e', success: false);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Chat AI Transaksi",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Contoh: 'Beli nasi goreng 15rb pakai gopay'",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            autofocus: true,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              hintText: "Ketik transaksi...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _isProcessing
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send, color: Colors.teal),
                      onPressed: _processChat,
                    ),
            ),
            onSubmitted: (_) => _processChat(),
          ),
        ],
      ),
    );
  }
}
