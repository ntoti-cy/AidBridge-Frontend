import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'aidbridge.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  first_name TEXT,
  second_name TEXT,
  national_id TEXT UNIQUE,
  contact TEXT,
  email TEXT,
  password TEXT,
  synced INTEGER DEFAULT 0
)
''');

 await database.execute('''
    CREATE TABLE codes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT UNIQUE,
      used INTEGER DEFAULT 0
    )
  ''');
      },
    );
  }
}