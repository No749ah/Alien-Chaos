import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('alienChaosDb.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
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
      type TEXT NOT NULL,
      value INTEGER NOT NULL,
      cost INTEGER NOT NULL,
      purchase_count INTEGER NOT NULL DEFAULT 0
    )
    ''';

    await db.execute(userTable);
    await db.execute(powerUpTable);
    await _insertDummyData(db); // Insert dummy data after creating tables
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      const addPurchaseCountColumn = '''
      ALTER TABLE powerups ADD COLUMN purchase_count INTEGER NOT NULL DEFAULT 0
      ''';
      await db.execute(addPurchaseCountColumn);
      await _insertDummyData(db);
    }
  }

  Future<void> _insertDummyData(Database db) async {
    final existingPowerUps = await db.query('powerups');
    if (existingPowerUps.isEmpty) {
      final powerUp1 = {
        'name': 'Alien Crowder',
        'type': 'click',
        'value': 1,
        'cost': 100,
        'purchase_count': 0,
      };

      final powerUp2 = {
        'name': 'Alien Magnet',
        'type': 'second',
        'value': 1,
        'cost': 200,
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
    int id = row['id'];
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
