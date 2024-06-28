import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('AlienChaosDb.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    const userTable = '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      aliens INTEGER NOT NULL
    )
    ''';

    const powerUpTable = '''
    CREATE TABLE powerups (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      display_name TEXT NOT NULL,
      type TEXT NOT NULL,
      value INTEGER NOT NULL,
      cost DOUBLE NOT NULL,
      multiplier DOUBLE NOT NULL DEFAULT 1,
      purchase_count INTEGER NOT NULL DEFAULT 0
    )
    ''';

    await db.execute(userTable);
    await db.execute(powerUpTable);
    await _insertDummyData(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
  }

  Future<void> _insertDummyData(Database db) async {
    final existingPowerUps = await db.query('powerups');
    if (existingPowerUps.isEmpty) {
      final powerUp1 = {
        'name': 'starter_apk',
        'display_name': 'Alien Crowder',
        'type': 'click',
        'value': 1,
        'multiplier': 1.3,
        'cost': 66.666666666666666666666666666667,
        'purchase_count': 1,
      };

      final powerUp2 = {
        'name': 'starter_aps',
        'display_name': 'Alien Magnet',
        'type': 'second',
        'value': 1,
        'multiplier': 1.2,
        'cost': 150,
        'purchase_count': 0,
      };

      await db.insert('powerups', powerUp1);
      await db.insert('powerups', powerUp2);
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('users', row);
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    int? id = row['id'];
    if (id == null) {
      throw ArgumentError('ID cannot be null for update');
    }
    return await db.update('users', row, where: 'id = ?', whereArgs: [id]);
  }


  Future<List<Map<String, dynamic>>> fetchPowerUps() async {
    final db = await instance.database;
    return await db.query('powerups');
  }

  Future<int> updatePowerUpPurchaseCount(int id, int newCount) async {
    final db = await instance.database;
    return await db.update(
      'powerups',
      {'purchase_count': newCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
