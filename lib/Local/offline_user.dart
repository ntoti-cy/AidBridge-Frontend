import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';

class OfflineUser {
  final DbHelper _dbHelper = DbHelper();
// Insert user locally
  Future<void> insertUser({
    required String firstName,
    required String secondName,
    required String nationalId,
    required String contact,
    required String email,
    required String password,
  }) async {
    final db = await _dbHelper.db;
    await db.insert('users', {
      'first_name': firstName,
      'second_name': secondName,
      'national_id': nationalId,
      'contact': contact,
      'email': email,
      'password': password,
      'synced': 0,
    });


  }
    // Retrieve user by email and password for offline login
  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
    String email,
    String password,
  ) async {
    final db = await _dbHelper.db;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty ? result.first : null;
  }

  // Get unsynced users
  Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
    final db = await _dbHelper.db;
    return await db.query('users', where: 'synced = 0');
  }

  // Mark user as synced
  Future<void> markUserAsSynced(String email) async {
    final db = await _dbHelper.db;
    await db.update(
      'users',
      {'synced': 1},
      where: 'email = ?',
      whereArgs: [email],
    );
  }


   // Insert access code
  Future<void> insertCode(String code) async {
    final db = await _dbHelper.db;
    await db.insert(
      'codes',
      {'code': code, 'used': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Get code by value
  Future<Map<String, dynamic>?> getCode(String code) async {
    final db = await _dbHelper.db;

    final result = await db.query(
      'codes',
      where: 'code = ?',
      whereArgs: [code],
    );

    return result.isNotEmpty ? result.first : null;
  }

  // Mark code as used
  Future<void> markCodeAsUsed(String code) async {
    final db = await _dbHelper.db;
    await db.update(
      'codes',
      {'used': 1},
      where: 'code = ?',
      whereArgs: [code],
    );
  }
}