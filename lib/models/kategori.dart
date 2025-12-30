class KategoriModel {
  final int? kategoriId;
  final String nama;
  final String tipe; // 'PEMASUKAN' atau 'PENGELUARAN'

  KategoriModel({
    this.kategoriId,
    required this.nama,
    required this.tipe,
  });

  // Mengubah Map dari database ke Object KategoriModel
  factory KategoriModel.fromMap(Map<String, dynamic> map) {
    return KategoriModel(
      kategoriId: map['kategori_id'],
      nama: map['nama'],
      tipe: map['tipe'],
    );
  }

  // Mengubah Object KategoriModel ke Map untuk disimpan di database
  Map<String, dynamic> toMap() {
    return {
      'kategori_id': kategoriId,
      'nama': nama,
      'tipe': tipe,
    };
  }
}
