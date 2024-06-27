import 'package:sqflite/sqflite.dart';

Future<void> insertDummyData(Database db) async {
  // Insert powerups only if they do not already exist
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

    // Debug print statements to confirm dummy data insertion
    print('Inserted PowerUp1: $powerUp1');
    print('Inserted PowerUp2: $powerUp2');
  }
}