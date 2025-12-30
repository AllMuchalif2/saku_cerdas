class Saldo {
  final int? saldoId;
  final String nama;
  final int total;

  Saldo({
    this.saldoId,
    required this.nama,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'saldo_id': saldoId,
      'nama': nama,
      'total': total,
    };
  }

  factory Saldo.fromMap(Map<String, dynamic> map) {
    return Saldo(
      saldoId: map['saldo_id'],
      nama: map['nama'],
      total: map['total'],
    );
  }
}
