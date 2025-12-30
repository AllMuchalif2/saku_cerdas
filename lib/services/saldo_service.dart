import 'package:saku_cerdas/db_helper.dart';
import '../models/saldo.dart';

class SaldoService {
  // CREATE
  Future<int> insertSaldo(Saldo saldo) async {
    final db = await DBHelper.db();
    return await db.insert('saldo', saldo.toMap());
  }

  // READ
  Future<List<Saldo>> getAllSaldo() async {
    final db = await DBHelper.db();
    final result = await db.query('saldo');

    return result.map((e) => Saldo.fromMap(e)).toList();
  }

  // UPDATE
  Future<int> updateSaldo(Saldo saldo) async {
    final db = await DBHelper.db();
    return await db.update(
      'saldo',
      saldo.toMap(),
      where: 'saldo_id = ?',
      whereArgs: [saldo.saldoId],
    );
  }

  // DELETE
  Future<int> deleteSaldo(int id) async {
    final db = await DBHelper.db();
    return await db.delete(
      'saldo',
      where: 'saldo_id = ?',
      whereArgs: [id],
    );
  }
}
