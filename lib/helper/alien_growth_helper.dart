import 'dart:async';
import '../db/database_helper.dart';
import '../models/users/user.dart';

class AlienGrowthHelper {
  static Timer? _timer;
  static int _aliensPerClick = 1;

  static Future<void> startAlienGrowth(User user, Function(int) updateAliens, bool Function() isMounted) async {
    stopAlienGrowth();
    int aliensPerSecond = await _calculateAliensPerSecond();

    if (aliensPerSecond > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        if (isMounted()) {
          user = await _fetchUser(user.id!);
          int newAliens = user.aliens + aliensPerSecond;
          user = user.copyWith(aliens: newAliens);
          await DatabaseHelper.instance.updateUser(user.toMap());
          updateAliens(newAliens);
        } else {
          stopAlienGrowth();
        }
      });
    }
  }

  static Future<User> _fetchUser(int userId) async {
    List<Map<String, dynamic>> users = await DatabaseHelper.instance.fetchUsers();
    return users.map((user) => User.fromMap(user)).firstWhere((user) => user.id == userId);
  }

  static Future<int> _calculateAliensPerSecond() async {
    List<Map<String, dynamic>> powerUps = await DatabaseHelper.instance.fetchPowerUps();
    int aliensPerSecond = 0;
    for (var powerUp in powerUps) {
      if (powerUp['type'] == 'second' && powerUp['value'] != null) {
        aliensPerSecond += powerUp['value'] as int;
      }
    }
    return aliensPerSecond;
  }

  static Future<void> initializePowerUps(User user, Function(int) updateAliens, bool Function() isMounted) async {
    int aliensPerClick = 1;
    List<Map<String, dynamic>> powerUps = await DatabaseHelper.instance.fetchPowerUps();
    for (var powerUp in powerUps) {
      if (powerUp['type'] == 'click' && powerUp['value'] != null) {
        aliensPerClick *= powerUp['value'] as int;
      }
    }
    _aliensPerClick = aliensPerClick;
    await startAlienGrowth(user, updateAliens, isMounted);
  }

  static Future<void> incrementAliens(User user, Function(int) updateAliens) async {
    user = await _fetchUser(user.id!);
    int newAliens = user.aliens + _aliensPerClick;
    user = user.copyWith(aliens: newAliens);
    await DatabaseHelper.instance.updateUser(user.toMap());
    updateAliens(newAliens);
  }

  static void stopAlienGrowth() {
    _timer?.cancel();
  }
}
