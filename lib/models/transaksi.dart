class Transaksi {
  final int? transaksiId;
  final int saldoId; // Foreign Key (Wajib)
  final int kategoriId; // Foreign Key (Wajib)
  final int? tabunganId; // Foreign Key (Opsional)
  final double jumlah; // REAL
  final String? tanggal; // ? TEXT

  Transaksi({
    this.transaksiId,
    required this.saldoId,
    required this.kategoriId,
    this.tabunganId,
    required this.jumlah,
    this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'transaksi_id': transaksiId,
      'saldo_id': saldoId,
      'kategori_id': kategoriId,
      'tabungan_id': tabunganId,
      'jumlah': jumlah,
      'tanggal': tanggal,
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      transaksiId: map['transaksi_id'],
      saldoId: map['saldo_id'],
      kategoriId: map['kategori_id'],
      tabunganId: map['tabungan_id'],
      jumlah: (map['jumlah'] as num).toDouble(),
      tanggal: map['tanggal'],
    );
  }
}
