import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/powerup.dart';

class GameState extends ChangeNotifier {
  User? _user;
  List<PowerUp> _powerUps = [];
  Timer? _timer;
  double _alienFraction = 0.0;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  User? get user => _user;
  List<PowerUp> get powerUps => _powerUps;

  Future<void> initialize() async {
    await _fetchUser();
    await fetchPowerUps();
    _startAlienGrowth();
  }

  Future<void> _fetchUser() async {
    List<Map<String, dynamic>> users = await _dbHelper.fetchUsers();
    if (users.isNotEmpty) {
      _user = User.fromMap(users.first);
      notifyListeners();
    }
  }

  Future<List<PowerUp>> fetchPowerUps() async {
    List<Map<String, dynamic>> powerUpData = await _dbHelper.fetchPowerUps();
    _powerUps = powerUpData.map((data) => PowerUp.fromMap(data)).toList();
    notifyListeners();
    return _powerUps;
  }

  Future<void> updatePowerUpPurchaseCount(int id, int newCount) async {
    await _dbHelper.updatePowerUpPurchaseCount(id, newCount);
    await fetchPowerUps();
    notifyListeners();
  }

  void _startAlienGrowth() {
    _timer?.cancel();
    double aliensPerSecond = calculateAliensPerSecond();
    double alienFraction = 0.0;

    if (aliensPerSecond > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        if (_user != null) {
          alienFraction += aliensPerSecond;

          alienFraction = double.parse(alienFraction.toStringAsFixed(5));

          int wholeAliens = alienFraction.floor();
          double fractionalAliens = alienFraction - wholeAliens;

          if (fractionalAliens >= 1.0) {
            wholeAliens += 1;
            fractionalAliens -= 1.0;
          }

          alienFraction = fractionalAliens;

          if (wholeAliens > 0) {
            _user!.aliens += wholeAliens;
            await _dbHelper.updateUser(_user!.toMap());
            notifyListeners();
          }
        }
      });
    }
  }

  double calculateAliensPerSecond() {
    double multiplier = 1.0;

    for (var powerUp in _powerUps) {
      if (powerUp.purchaseCount == 0) {
        return 0.0;
      }
      if (powerUp.type == 'second' || powerUp.type == 'multiplier') {
        multiplier *= pow(powerUp.multiplier, powerUp.purchaseCount) * user!.prestige;
      }
    }

    return (multiplier - 1);
  }

  double calculateAliensPerClick() {
    for (var powerUp in _powerUps) {
      if (powerUp.type == 'click' || powerUp.type == 'multiplier') {
        if (powerUp.name == 'starter_apk') {
          return (pow(powerUp.multiplier, powerUp.purchaseCount)/powerUp.multiplier)*user!.prestige*1;
        }
        else {
          return ((pow(powerUp.multiplier, powerUp.purchaseCount))*user!.prestige)*1;
        }
      }
    }
    return 0.0;
  }

  num getFinalMultiplier(PowerUp powerUp) {
    if (powerUp.purchaseCount == 0 && powerUp.type == 'second') {
      return 1.0;
    }

    if (powerUp.type == 'click') {
      if (powerUp.name == 'starter_apk') {
        return (pow(powerUp.multiplier, powerUp.purchaseCount) / powerUp.multiplier) * user!.prestige;
      } else {
        return pow(powerUp.multiplier, powerUp.purchaseCount) * user!.prestige;
      }
    } else if (powerUp.type == 'second' || powerUp.type == 'multiplier') {
      return pow(powerUp.multiplier, powerUp.purchaseCount) * user!.prestige;
    }

    return 1.0;
  }

  Future<void> incrementAliens() async {
    if (_user != null) {
      double aliensPerClick = calculateAliensPerClick();
      _alienFraction += aliensPerClick;

      _alienFraction = double.parse(_alienFraction.toStringAsFixed(5));

      int wholeAliens = _alienFraction.floor();
      double fractionalAliens = _alienFraction - wholeAliens;

      if (fractionalAliens >= 1.0) {
        wholeAliens += 1;
        fractionalAliens -= 1.0;
      }

      _alienFraction = fractionalAliens;

      if (wholeAliens > 0) {
        _user!.aliens += wholeAliens;
        await _dbHelper.updateUser(_user!.toMap());
        notifyListeners();
      }
    }
  }

  Future<void> updateUser(Map<String, dynamic> userMap) async {
    await _dbHelper.updateUser(userMap);
    notifyListeners();
  }

  Future<void> purchasePowerUp(PowerUp powerUp) async {
    int currentCost = calculatePowerUpCost(powerUp);
    if (_user != null && _user!.aliens >= currentCost) {
      _user!.aliens -= currentCost;
      powerUp.purchaseCount += 1;
      await _dbHelper.updatePowerUpPurchaseCount(powerUp.id, powerUp.purchaseCount);
      await _dbHelper.updateUser(_user!.toMap());
      notifyListeners();
      initialize();
    } else {
      throw Exception('Not enough aliens to purchase ${powerUp.display_name}');
    }
  }

  Future<void> setSpinDate() async{
    _user!.spinDate = DateTime.now();
    await _dbHelper.updateUser(_user!.toMap());
    notifyListeners();
  }

  int calculatePowerUpCost(PowerUp powerUp) {
    return (powerUp.baseCost * pow(1.5, powerUp.purchaseCount)).toInt();
  }

  double calculatePrestigePoints(int totalAliens, int totalPowerUps, double prestigeMultiplier, double currentPrestige) {
    double basePoints = (log(totalAliens + 1) + totalPowerUps) * prestigeMultiplier;
    double bonusPoints = totalPowerUps * 0.25;
    num divisor = currentPrestige < 1 ? 1 : currentPrestige;

    return ((basePoints + bonusPoints) / divisor);
  }

  Future<void> prestige() async {
    if (_user != null) {
      int totalAliens = _user!.aliens;
      int totalPowerUps = powerUps.fold(0, (sum, powerUp) => sum + powerUp.purchaseCount);
      double prestigeMultiplier = 0.01;

      double prestigePoints = calculatePrestigePoints(totalAliens, totalPowerUps, prestigeMultiplier, _user!.prestige);

      _user!.prestige += prestigePoints;
      _user!.aliens = 0;

      for (var powerUp in powerUps) {
        if (powerUp.name == 'starter_apk') {
          powerUp.purchaseCount = 1;
        } else {
          powerUp.purchaseCount = 0;
        }
        await _dbHelper.updatePowerUp(powerUp);
      }

      await _dbHelper.updateUser(_user!.toMap());
      notifyListeners();
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
