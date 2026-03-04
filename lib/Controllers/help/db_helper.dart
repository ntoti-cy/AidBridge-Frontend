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
            name TEXT,
            aid_token TEXT UNIQUE
            national_id TEXT UNIQUE,
            token_status TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE tokens(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            token TEXT UNIQUE,
            national_id TEXT,
            used INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // Insert a single beneficiary
  Future<void> insertBeneficiary(Beneficiary b) async {
    final dbClient = await database;
    await dbClient.insert(
      'beneficiaries',
      b.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple beneficiaries
  Future<void> insertBeneficiaries(List<Beneficiary> list) async {
    final dbClient = await database;
    final batch = dbClient.batch();
    for (var b in list) {
      batch.insert(
        'beneficiaries',
        b.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    //print('Synced ${list.length} beneficiaries');
  }

  // Get all beneficiaries
  Future<List<Beneficiary>> getBeneficiaries() async {
    final dbClient = await database;
    final maps = await dbClient.query('beneficiaries');
    return maps.map((m) => Beneficiary.fromJson(m)).toList();
  }

  // Insert a token
  Future<void> insertToken(Token t) async {
    final dbClient = await database;
    await dbClient.insert(
      'tokens',
      t.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all tokens
  Future<List<Token>> getTokens() async {
    final dbClient = await database;
    final maps = await dbClient.query('tokens');
    return maps.map((m) => Token.fromJson(m)).toList();
  }

  // Mark token as used
  Future<void> markTokenUsed(String tokenValue) async {
    final dbClient = await database;
    await dbClient.update(
      'tokens',
      {'used': 1},
      where: 'token = ?',
      whereArgs: [tokenValue],
    );
  }

  // Offline token status check
 Future<String> getTokenStatus(String tokenValue) async {
  final dbClient = await database;

  // Query beneficiary by aid_token
  final result = await dbClient.query(
    'beneficiaries',
    where: 'aid_token = ?',
    whereArgs: [tokenValue],
  );

  if (result.isEmpty) return "Invalid"; // token not found

  // token_status from API: 'active' = valid, anything else = used
  bool isUsed = result.first['token_status'] != 'active';

  return isUsed ? "Used" : "Valid";
}
}