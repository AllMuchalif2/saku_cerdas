class Transaksi {
  final int? transaksiId;
  final int saldoId;
  final int kategoriId;
  final int? tabunganId;
  final String nama;
  final double jumlah;
  final String? tanggal;

  Transaksi({
    this.transaksiId,
    required this.saldoId,
    required this.kategoriId,
    this.tabunganId,
    required this.nama,
    required this.jumlah,
    this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'transaksi_id': transaksiId,
      'saldo_id': saldoId,
      'kategori_id': kategoriId,
      'tabungan_id': tabunganId,
      'nama': nama,
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
      nama: map['nama'],
      jumlah: (map['jumlah'] as num).toDouble(),
      tanggal: map['tanggal'],
    );
  }
}
