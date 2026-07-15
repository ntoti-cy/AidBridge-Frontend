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
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE beneficiaries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            aid_token TEXT UNIQUE,
            national_id TEXT UNIQUE,
            token_status TEXT,
            total_members INTEGER,
            dependents_count INTEGER,
            income_level REAL,
            disability_present INTEGER,
            distribution_center TEXT
          )
        ''');

    await db.execute('''
          CREATE TABLE tokens(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aid_token TEXT UNIQUE,
    token_status TEXT,
    center_name TEXT,
    token_issued_at TEXT,
    expiry_time TEXT
)
        ''');

    await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            second_name TEXT,
            national_id TEXT UNIQUE,
            contact  TEXT,
            email TEXT UNIQUE,
            password_hash TEXT,
            role TEXT,
            requires_password_change INTEGER DEFAULT 0,
            is_profile_complete INTEGER DEFAULT 1,
            synced INTEGER DEFAULT 0            
          )
        ''');

    await db.execute('''
          CREATE TABLE codes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT UNIQUE,
            used INTEGER DEFAULT 0
          )
        ''');

    await db.execute('''
  CREATE TABLE history(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aid_token TEXT UNIQUE,
    token_status TEXT,
    token_issued_at TEXT,
    center_name TEXT,
    expiry_time TEXT
)
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        second_name TEXT,
        national_id TEXT UNIQUE,
        contact TEXT,
        email TEXT UNIQUE,
        password_hash TEXT,
        role TEXT,
        requires_password_change INTEGER DEFAULT 0,
        is_profile_complete INTEGER DEFAULT 1,
        synced INTEGER DEFAULT 0
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS codes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE,
        used INTEGER DEFAULT 0
      )
    ''');

      await db.execute('''
  CREATE TABLE IF NOT EXISTS history(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aid_token TEXT UNIQUE,
    token_status TEXT,
    token_issued_at TEXT,
    center_name TEXT,
    expiry_time TEXT
)
''');

      await db.execute('''
CREATE TABLE pending_profile(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  total_members INTEGER,
  dependents_count INTEGER,
  income_level REAL,
  disability_present INTEGER,
  center_id INTEGER,
  synced INTEGER DEFAULT 0
)
''');
    }

    Future<void> addColumn(String sql) async {
      try {
        await db.execute(sql);
      } catch (_) {}
    }

    await addColumn("ALTER TABLE users ADD COLUMN password_hash TEXT");

    await addColumn("ALTER TABLE users ADD COLUMN role TEXT");

    await addColumn(
      "ALTER TABLE users ADD COLUMN requires_password_change INTEGER DEFAULT 0",
    );

    await addColumn(
      "ALTER TABLE users ADD COLUMN is_profile_complete INTEGER DEFAULT 1",
    );

    await addColumn("ALTER TABLE users ADD COLUMN synced INTEGER DEFAULT 0");

    await addColumn("ALTER TABLE tokens ADD COLUMN token_status TEXT");

    await addColumn("ALTER TABLE tokens ADD COLUMN center_name TEXT");

    await addColumn("ALTER TABLE tokens ADD COLUMN token_issued_at TEXT");

    await addColumn("ALTER TABLE tokens ADD COLUMN expiry_time TEXT");
    await addColumn(
      "ALTER TABLE beneficiaries ADD COLUMN total_members INTEGER DEFAULT 0",
    );

    await addColumn(
      "ALTER TABLE beneficiaries ADD COLUMN dependents_count INTEGER DEFAULT 0",
    );

    await addColumn(
      "ALTER TABLE beneficiaries ADD COLUMN income_level REAL DEFAULT 0",
    );

    await addColumn(
      "ALTER TABLE beneficiaries ADD COLUMN disability_present INTEGER DEFAULT 0",
    );

    await addColumn(
      "ALTER TABLE beneficiaries ADD COLUMN distribution_center TEXT",
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
  }

  //Clear beneficiaries before inserting new ones
  Future<void> clearBeneficiaries() async {
    final dbClient = await database;
    await dbClient.delete('beneficiaries');
  }

  // Get all beneficiaries
  Future<List<Beneficiary>> getBeneficiaries() async {
    final dbClient = await database;
    final maps = await dbClient.query('beneficiaries');
    return maps.map((m) => Beneficiary.fromJson(m)).toList();
  }

  // Insert a token
  Future<void> insertToken(Token token) async {
    final dbClient = await database;
    await dbClient.insert(
      'tokens',
      token.toMap(),
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
      {'token_status': 'used'},
      where: 'aid_token = ?',
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

    if (result.isEmpty) return "Invalid";
    return result.first['token_status'] as String? ?? "Invalid";
  }

  // Mark a beneficiary token as used in the beneficiaries table
  Future<void> markBeneficiaryTokenUsed(String tokenValue) async {
    final dbClient = await database;
    await dbClient.update(
      'beneficiaries',
      {'token_status': 'used'},
      where: 'aid_token = ?',
      whereArgs: [tokenValue],
    );
  }

  //User (offline login) operations
  Future<void> upsertUser(Map<String, dynamic> userData) async {
    final dbClient = await database;

    try {
      await dbClient.insert(
        'users',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("SQLite user insert failed: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final dbClient = await database;
    final result = await dbClient.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Get Last Cached User
  Future<Map<String, dynamic>?> getLastUser() async {
    final dbClient = await database;

    final result = await dbClient.query('users', orderBy: 'id DESC', limit: 1);

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // Update User
  Future<void> updateUser(String email, Map<String, dynamic> values) async {
    final dbClient = await database;

    await dbClient.update(
      'users',
      values,
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Delete User
  Future<void> deleteUser(String email) async {
    final dbClient = await database;

    await dbClient.delete('users', where: 'email = ?', whereArgs: [email]);
  }

  Future<void> markUserSynced(String email) async {
    final dbClient = await database;
    await dbClient.update(
      'users',
      {'synced': 1},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  //Code operations
  Future<void> insertCode(String code) async {
    final dbClient = await database;
    await dbClient.insert('codes', {
      'code': code,
      'used': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Map<String, dynamic>?> getCode(String code) async {
    final dbClient = await database;
    final result = await dbClient.query(
      'codes',
      where: 'code = ?',
      whereArgs: [code],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> markCodeUsed(String code) async {
    final dbClient = await database;
    await dbClient.update(
      'codes',
      {'used': 1},
      where: 'code = ?',
      whereArgs: [code],
    );
  }

  // Save Token History
  Future<void> saveHistory(List<Map<String, dynamic>> history) async {
    final dbClient = await database;

    await dbClient.delete("history");

    final batch = dbClient.batch();

    for (final item in history) {
      batch.insert("history", {
        "aid_token": item["aid_token"],
        "token_status": item["token_status"],
        "token_issued_at": item["token_issued_at"],
        "center_name":
            item["center_name"] ?? item["center"] ?? "Distribution Center",
        "expiry_time": item["expiry_time"],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // Get Token History
  Future<List<Map<String, dynamic>>> getHistory() async {
    final dbClient = await database;

    final result = await dbClient.query("history", orderBy: "id DESC");

    return result;
  }

  Future<void> savePendingProfile(Map<String, dynamic> profile) async {
    final dbClient = await database;

    // Only keep one pending profile
    await dbClient.delete("pending_profile");

    await dbClient.insert("pending_profile", {
      "total_members": profile["total_members"],
      "dependents_count": profile["dependents_count"],
      "income_level": profile["income_level"],
      "disability_present": profile["disability_present"] == true ? 1 : 0,
      "center_id": profile["center_id"],
      "synced": 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //Getting Pending Profile
  Future<Map<String, dynamic>?> getPendingProfile() async {
    final dbClient = await database;

    final result = await dbClient.query("pending_profile", limit: 1);

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<void> deletePendingProfile() async {
    final dbClient = await database;

    await dbClient.delete("pending_profile");
  }

  Future<bool> hasPendingProfile() async {
    final dbClient = await database;

    final result = await dbClient.query("pending_profile", limit: 1);

    return result.isNotEmpty;
  }

  Future<void> markPendingProfileSynced() async {
    final dbClient = await database;

    await dbClient.update("pending_profile", {"synced": 1});
  }
}
