

import 'package:aid_bridge/Local/db_helper.dart';

class CodeRepo {
  final DbHelper _dbHelper = DbHelper();

  Future<void> insertCode(String code) async {
    final db = await _dbHelper.db;
    await db.insert('codes', {
      'code': code,
      'is_used': 0,
    });
  }

  Future<Map<String, dynamic>?> getCode(String code) async {
    final db = await _dbHelper.db;

    final result = await db.query(
      'codes',
      where: 'code = ?',
      whereArgs: [code],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<void> markAsUsed(String code) async {
    final db = await _dbHelper.db;

    await db.update(
      'codes',
      {'is_used': 1},
      where: 'code = ?',
      whereArgs: [code],
    );
  }
}