class Tabungan {
  final int? tabunganId;
  final String nama;
  final double targetJumlah;
  final double jumlah;

  Tabungan({
    this.tabunganId,
    required this.nama,
    required this.targetJumlah,
    this.jumlah = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'tabungan_id': tabunganId,
      'nama': nama,
      'target_jumlah': targetJumlah,
      'jumlah': jumlah,
    };
  }

  factory Tabungan.fromMap(Map<String, dynamic> map) {
    return Tabungan(
      tabunganId: map['tabungan_id'],
      nama: map['nama'],
      targetJumlah: map['target_jumlah'],
      jumlah: map['jumlah'] ?? 0,
    );
  }
}
