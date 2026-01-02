import '../db_helper.dart';
import '../models/saldo.dart';

class SaldoService {
  static Future<int> insertSaldo(Saldo saldo) async {
    final db = await DBHelper.db();
    return await db.insert('saldo', saldo.toMap());
  }

  static Future<List<Saldo>> getAllSaldo() async {
    final db = await DBHelper.db();
    final result = await db.query('saldo');
    return result.map((e) => Saldo.fromMap(e)).toList();
  }

  static Future<int> updateSaldo(Saldo saldo) async {
    final db = await DBHelper.db();
    return await db.update(
      'saldo',
      saldo.toMap(),
      where: 'saldo_id = ?',
      whereArgs: [saldo.saldoId],
    );
  }

  static Future<int> deleteSaldo(int id) async {
    final db = await DBHelper.db();
    return await db.delete(
      'saldo',
      where: 'saldo_id = ?',
      whereArgs: [id],
    );
  }

  // 🔥 TOP UP SALDO (ANTI MINUS)
  static Future<void> topUpSaldo({
    required int saldoId,
    required int nominal,
  }) async {
    final db = await DBHelper.db();

    final result = await db.query(
      'saldo',
      where: 'saldo_id = ?',
      whereArgs: [saldoId],
    );

    final saldoSekarang = result.first['total'] as int;
    final totalBaru = saldoSekarang + nominal;

    await db.update(
      'saldo',
      {'total': totalBaru},
      where: 'saldo_id = ?',
      whereArgs: [saldoId],
    );
  }

  static Future<void> deleteAllSaldo() async {
    final db = await DBHelper.db();
    await db.delete('saldo');
  }
}
