class Tabungan {
  final int? tabunganId;
  final int? saldoId;
  final String nama;
  final double targetJumlah;
  final double jumlah;
  final String? tenggatWaktu;

  Tabungan({
    this.tabunganId,
    this.saldoId,
    required this.nama,
    required this.targetJumlah,
    this.jumlah = 0,
    this.tenggatWaktu,
  });

  Map<String, dynamic> toMap() {
    return {
      'tabungan_id': tabunganId,
      'saldo_id': saldoId,
      'nama': nama,
      'target_jumlah': targetJumlah,
      'jumlah': jumlah,
      'tenggat_waktu': tenggatWaktu,
    };
  }

  factory Tabungan.fromMap(Map<String, dynamic> map) {
    return Tabungan(
      tabunganId: map['tabungan_id'],
      saldoId: map['saldo_id'],
      nama: map['nama'],
      targetJumlah: map['target_jumlah'],
      jumlah: map['jumlah'] ?? 0,
      tenggatWaktu: map['tenggat_waktu'],
    );
  }
}
