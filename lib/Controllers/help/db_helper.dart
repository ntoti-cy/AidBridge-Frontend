import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../Models/beneficiary_model.dart';
import '../../Models/token_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'aidbridge.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE beneficiaries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            second_name TEXT,
            national_id TEXT UNIQUE,
            contact TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE tokens(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            token TEXT UNIQUE,
            used INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // Insert a beneficiary
  Future<void> insertBeneficiary(Beneficiary b) async {
    final db = await database;
    await db.insert(
      'beneficiaries',
      b.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all beneficiaries
  Future<List<Beneficiary>> getBeneficiaries() async {
    final db = await database;
    final maps = await db.query('beneficiaries');
    return maps.map((m) => Beneficiary.fromJson(m)).toList();
  }

  // Insert a token
  Future<void> insertToken(Token t) async {
    final db = await database;
    await db.insert(
      'tokens',
      t.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all tokens
  Future<List<Token>> getTokens() async {
    final db = await database;
    final maps = await db.query('tokens');
    return maps.map((m) => Token.fromJson(m)).toList();
  }

  // Mark a token as used
  Future<void> markTokenUsed(String tokenValue) async {
    final db = await database;
    await db.update(
      'tokens',
      {'used': 1},
      where: 'token = ?',
      whereArgs: [tokenValue],
    );
  }
}
