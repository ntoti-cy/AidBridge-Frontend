import 'dart:convert';

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
      version: 8,
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
            distribution_center TEXT,
            distribution_session_id INTEGER
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
            distribution_center TEXT,
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

    await db.execute('''
CREATE TABLE pending_sync(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  action TEXT NOT NULL,
  payload TEXT NOT NULL,
  created_at TEXT NOT NULL,
  synced INTEGER DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE offline_collections(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  aid_token TEXT UNIQUE,
  beneficiary_id INTEGER,
  officer_id INTEGER,
  collection_time TEXT,
  distribution_center TEXT,
  distribution_session_id INTEGER,
  synced INTEGER DEFAULT 0
)
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 8) {
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
  CREATE TABLE IF NOT EXISTS pending_sync(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action TEXT NOT NULL,
    payload TEXT NOT NULL,
    created_at TEXT NOT NULL,
    synced INTEGER DEFAULT 0
  )
  ''');
      await db.execute('''
CREATE TABLE IF NOT EXISTS pending_profile(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  total_members INTEGER,
  dependents_count INTEGER,
  income_level REAL,
  disability_present INTEGER,
  center_id INTEGER,
  synced INTEGER DEFAULT 0
)
''');

      await db.execute('''
  CREATE TABLE IF NOT EXISTS offline_collections(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aid_token TEXT UNIQUE,
    beneficiary_id INTEGER,
    officer_id INTEGER,
    collection_time TEXT,
    distribution_center TEXT,
    distribution_session_id INTEGER,
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
    await addColumn("ALTER TABLE users ADD COLUMN distribution_center TEXT");
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

  Future<void> addPendingSync({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final dbClient = await database;

    await dbClient.insert("pending_sync", {
      "action": action,
      "payload": jsonEncode(payload),
      "created_at": DateTime.now().toIso8601String(),
      "synced": 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final dbClient = await database;

    final result = await dbClient.query(
      "pending_sync",
      where: "synced = ?",
      whereArgs: [0],
      orderBy: "id ASC",
    );

    return result.map((e) {
      final item = Map<String, dynamic>.from(e);

      item["payload"] = jsonDecode(item["payload"] as String);

      return item;
    }).toList();
  }

  Future<void> markPendingSyncComplete(int id) async {
    final dbClient = await database;

    await dbClient.update(
      "pending_sync",
      {"synced": 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deletePendingSync(int id) async {
    final dbClient = await database;

    await dbClient.delete("pending_sync", where: "id = ?", whereArgs: [id]);
  }

  Future<void> clearPendingSync() async {
    final dbClient = await database;

    await dbClient.delete("pending_sync");
  }

  Future<int> pendingSyncCount() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery(
      "SELECT COUNT(*) as total FROM pending_sync WHERE synced = 0",
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  //Save Offline Collection
  Future<void> saveOfflineCollection({
    required String aidToken,
    required int beneficiaryId,
    required int officerId,
    required String distributionCenter,
    required int distributionSessionId,
  }) async {
    final dbClient = await database;

    await dbClient.insert("offline_collections", {
      "aid_token": aidToken,
      "beneficiary_id": beneficiaryId,
      "officer_id": officerId,
      "collection_time": DateTime.now().toIso8601String(),
      "distribution_center": distributionCenter,
      "distribution_session_id": distributionSessionId,
      "synced": 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get All Offline Collections
  Future<List<Map<String, dynamic>>> getOfflineCollections() async {
    final dbClient = await database;

    return await dbClient.query(
      "offline_collections",
      orderBy: "collection_time DESC",
    );
  }

  //Get Unsynced Collection
  Future<List<Map<String, dynamic>>> getUnsyncedCollections() async {
    final dbClient = await database;

    return await dbClient.query(
      "offline_collections",
      where: "synced = ?",
      whereArgs: [0],
      orderBy: "collection_time ASC",
    );
  }

  //Delete One Collection
  Future<void> deleteOfflineCollection(int id) async {
    final dbClient = await database;

    await dbClient.delete(
      "offline_collections",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  //Clear All Collections
  Future<void> clearOfflineCollections() async {
    final dbClient = await database;

    await dbClient.delete("offline_collections");
  }

  //Has Unsynced Collections
  Future<bool> hasUnsyncedCollections() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery(
      "SELECT COUNT(*) as total FROM offline_collections WHERE synced = 0",
    );

    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  //Count Offline Collections
  Future<int> offlineCollectionCount() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery(
      "SELECT COUNT(*) as total FROM offline_collections",
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  //Save Collection  and Queue Sync
  Future<void> collectAidOffline({
    required String aidToken,
    required int beneficiaryId,
    required int officerId,
    required String distributionCenter,
    required int distributionSessionId,
  }) async {
    final dbClient = await database;

    await dbClient.transaction((txn) async {
      await txn.insert("offline_collections", {
        "aid_token": aidToken,
        "beneficiary_id": beneficiaryId,
        "officer_id": officerId,
        "collection_time": DateTime.now().toIso8601String(),
        "distribution_center": distributionCenter,
        "distribution_session_id": distributionSessionId,

        "synced": 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.update(
        "beneficiaries",
        {"token_status": "used"},
        where: "aid_token = ?",
        whereArgs: [aidToken],
      );

      await txn.insert("pending_sync", {
        "action": "collect_aid",
        "payload": jsonEncode({
          "aid_token": aidToken,
          "beneficiary_id": beneficiaryId,
          "officer_id": officerId,
          "distribution_center": distributionCenter,
          "distribution_session_id": distributionSessionId,
        }),
        "created_at": DateTime.now().toIso8601String(),
        "synced": 0,
      });
    });
  }

  // get Beneficiary by Aid Token , National ID and  Name
  Future<Beneficiary?> getBeneficiaryByToken(String aidToken) async {
    final dbClient = await database;

    final result = await dbClient.query(
      "beneficiaries",
      where: "aid_token = ?",
      whereArgs: [aidToken],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Beneficiary.fromJson(result.first);
  }

  Future<Beneficiary?> getBeneficiaryByNationalId(String nationalId) async {
    final dbClient = await database;

    final result = await dbClient.query(
      "beneficiaries",
      where: "national_id = ?",
      whereArgs: [nationalId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Beneficiary.fromJson(result.first);
  }

  Future<List<Beneficiary>> searchBeneficiaries(String keyword) async {
    final dbClient = await database;

    final result = await dbClient.query(
      "beneficiaries",
      where: "name LIKE ?",
      whereArgs: ["%$keyword%"],
    );

    return result.map((e) => Beneficiary.fromJson(e)).toList();
  }

  //Get Token by Value
  Future<Token?> getTokenByValue(String aidToken) async {
    final dbClient = await database;

    final result = await dbClient.query(
      "tokens",
      where: "aid_token = ?",
      whereArgs: [aidToken],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Token.fromJson(result.first);
  }

  //Check Whether Token, Beneficiary Exists
  Future<bool> tokenExists(String aidToken) async {
    final dbClient = await database;

    final result = await dbClient.query(
      "tokens",
      where: "aid_token = ?",
      whereArgs: [aidToken],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<bool> beneficiaryExists(String nationalId) async {
    final dbClient = await database;

    final result = await dbClient.query(
      "beneficiaries",
      where: "national_id = ?",
      whereArgs: [nationalId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<String?> getBeneficiaryStatus(String aidToken) async {
    final dbClient = await database;

    final result = await dbClient.query(
      "beneficiaries",
      columns: ["token_status"],
      where: "aid_token = ?",
      whereArgs: [aidToken],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return result.first["token_status"] as String?;
  }

  //Verify Beneficiary can Collect Aid
  Future<bool> canCollectAid(String aidToken) async {
    final beneficiary = await getBeneficiaryByToken(aidToken);

    if (beneficiary == null) {
      return false;
    }

    return beneficiary.tokenStatus.toLowerCase() == "active";
  }

  Future<List<Beneficiary>> getActiveBeneficiaries() async {
    final dbClient = await database;

    final result = await dbClient.query(
      "beneficiaries",
      where: "token_status = ?",
      whereArgs: ["active"],
    );

    return result.map((e) => Beneficiary.fromJson(e)).toList();
  }

  Future<List<Beneficiary>> getUsedBeneficiaries() async {
    final dbClient = await database;

    final result = await dbClient.query(
      "beneficiaries",
      where: "token_status = ?",
      whereArgs: ["used"],
    );

    return result.map((e) => Beneficiary.fromJson(e)).toList();
  }

  Future<List<Beneficiary>> getExpiredBeneficiaries() async {
    final dbClient = await database;

    final result = await dbClient.query(
      "beneficiaries",
      where: "token_status = ?",
      whereArgs: ["expired"],
    );

    return result.map((e) => Beneficiary.fromJson(e)).toList();
  }

  Future<List<Beneficiary>> getBeneficiariesByCenter(String center) async {
    final dbClient = await database;

    final result = await dbClient.query(
      "beneficiaries",
      where: "distribution_center = ?",
      whereArgs: [center],
    );

    return result.map((e) => Beneficiary.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
    final dbClient = await database;

    return await dbClient.query("users", where: "synced = ?", whereArgs: [0]);
  }

  Future<Map<String, dynamic>?> getUserByNationalId(String nationalId) async {
    final dbClient = await database;

    final result = await dbClient.query(
      "users",
      where: "national_id = ?",
      whereArgs: [nationalId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return result.first;
  }

  //Clear Tokens
  Future<void> clearTokens() async {
    final dbClient = await database;

    await dbClient.delete("tokens");
  }

  //Clear History
  Future<void> clearHistory() async {
    final dbClient = await database;

    await dbClient.delete("history");
  }

  //Clear Users
  Future<void> clearUsers() async {
    final dbClient = await database;

    await dbClient.delete("users");
  }

  //Clear Codes
  Future<void> clearCodes() async {
    final dbClient = await database;

    await dbClient.delete("codes");
  }

  Future<void> clearPendingProfile() async {
    final dbClient = await database;

    await dbClient.delete("pending_profile");
  }

  //Reset Beneficiary Statuses, Token Statuses
  Future<void> resetBeneficiaryStatuses() async {
    final dbClient = await database;

    await dbClient.update("beneficiaries", {"token_status": "active"});
  }

  Future<void> resetTokenStatuses() async {
    final dbClient = await database;

    await dbClient.update("tokens", {"token_status": "active"});
  }

  //Officer Logout Cleanup
  Future<void> clearOfficerOfflineData() async {
    final dbClient = await database;

    await dbClient.transaction((txn) async {
      await txn.delete("beneficiaries");
      await txn.delete("tokens");
      await txn.delete("history");
      await txn.delete("codes");
      await txn.delete("pending_sync");
      await txn.delete("offline_collections");
    });
  }

  Future<void> clearUsedCodes() async {
    final dbClient = await database;

    await dbClient.delete("codes", where: "used = ?", whereArgs: [1]);
  }

  //Vacuum Database
  Future<void> vacuumDatabase() async {
    final dbClient = await database;

    await dbClient.execute("VACUUM");
  }

  //Full Refresh Before Download
  Future<void> prepareForFreshDownload() async {
    final dbClient = await database;

    await dbClient.transaction((txn) async {
      await txn.delete("beneficiaries");
      await txn.delete("tokens");
      await txn.delete("history");
      await txn.delete("codes");
    });
  }

  Future<int> getTotalBeneficiaries() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery(
      "SELECT COUNT(*) as total FROM beneficiaries",
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getActiveBeneficiaryCount() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery(
      '''
    SELECT COUNT(*) as total
    FROM beneficiaries
    WHERE token_status = ?
    ''',
      ["active"],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getUsedBeneficiaryCount() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery(
      '''
    SELECT COUNT(*) as total
    FROM beneficiaries
    WHERE token_status = ?
    ''',
      ["used"],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getExpiredBeneficiaryCount() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery(
      '''
    SELECT COUNT(*) as total
    FROM beneficiaries
    WHERE token_status = ?
    ''',
      ["expired"],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  //Beneficiareies not served
  Future<int> getRemainingBeneficiaries() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery(
      '''
    SELECT COUNT(*) as total
    FROM beneficiaries
    WHERE token_status != ?
    ''',
      ["used"],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPendingSyncCount() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery('''
    SELECT COUNT(*) as total
    FROM pending_sync
    WHERE synced = 0
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPendingProfileCount() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery('''
    SELECT COUNT(*) as total
    FROM pending_profile
    WHERE synced = 0
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getOfflineCollectionsCount() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery('''
    SELECT COUNT(*) as total
    FROM offline_collections
    WHERE synced = 0
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalOfflineCollections() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery('''
    SELECT COUNT(*) as total
    FROM offline_collections
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getDistributionProgress() async {
    final total = await getTotalBeneficiaries();

    if (total == 0) {
      return 0;
    }

    final served = await getUsedBeneficiaryCount();

    return served / total;
  }

  //Synchronization
  Future<List<Map<String, dynamic>>> pendingSync() async {
    final dbClient = await database;

    return await dbClient.query(
      "pending_sync",
      where: "synced = ?",
      whereArgs: [0],
      orderBy: "created_at ASC",
    );
  }

  Future<void> markPendingSyncAsSynced(int id) async {
    final dbClient = await database;

    await dbClient.update(
      "pending_sync",
      {"synced": 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> removeSyncedRecords() async {
    final dbClient = await database;

    await dbClient.delete("pending_sync", where: "synced = ?", whereArgs: [1]);
  }

  Future<void> removePendingSync(int id) async {
    final dbClient = await database;

    await dbClient.delete("pending_sync", where: "id = ?", whereArgs: [id]);
  }

  Future<bool> hasPendingSynchronization() async {
    final dbClient = await database;

    final result = await dbClient.rawQuery('''
    SELECT COUNT(*) as total
    FROM pending_sync
    WHERE synced = 0
  ''');

    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
}
