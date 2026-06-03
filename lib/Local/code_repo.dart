

import 'package:aid_bridge/Local/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class CodeRepo {
  final DbHelper _dbHelper = DbHelper();

  Future<void> insertCode(String code) async {
    final db = await _dbHelper.db;
    await db.insert('codes', {
      'code': code,
      'used': 0,
    },
     conflictAlgorithm: ConflictAlgorithm.ignore,
    );
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
      {'used': 1},
      where: 'code = ?',
      whereArgs: [code],
    );
  }
}