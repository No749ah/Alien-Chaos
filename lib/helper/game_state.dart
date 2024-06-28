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
    await _fetchPowerUps();
    _startAlienGrowth();
  }

  Future<void> _fetchUser() async {
    List<Map<String, dynamic>> users = await _dbHelper.fetchUsers();
    if (users.isNotEmpty) {
      _user = User.fromMap(users.first);
      notifyListeners();
    }
  }

  Future<void> _fetchPowerUps() async {
    List<Map<String, dynamic>> powerUpData = await _dbHelper.fetchPowerUps();
    _powerUps = powerUpData.map((data) => PowerUp.fromMap(data)).toList();
    notifyListeners();
  }

  void _startAlienGrowth() {
    _timer?.cancel();
    double aliensPerSecond = calculateAliensPerSecond();
    print(calculateAliensPerSecond());
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
      if (powerUp.type == 'second') {
        multiplier *= pow(powerUp.multiplier, powerUp.purchaseCount);
      }
    }

    return ((multiplier) -1);
  }

  double calculateAliensPerClick() {
    double multiplier = 0.0;
    for (var powerUp in _powerUps) {
      if (powerUp.type == 'click') {
        if (powerUp.name == 'starter_apk')
          multiplier = pow(powerUp.multiplier, powerUp.purchaseCount)/powerUp.multiplier;
        else {
          multiplier = pow(powerUp.multiplier, powerUp.purchaseCount)*1;
        }
      }
    }
    return multiplier;
  }

  num getFinalMultiplier(PowerUp powerUp) {
    if (powerUp.type == 'click') {
      if (powerUp.name == 'starter_apk')
        return pow(powerUp.multiplier, powerUp.purchaseCount)/powerUp.multiplier;
      else {
        return pow(powerUp.multiplier, powerUp.purchaseCount)*1;
      }
    } else if (powerUp.type == 'second') {
      return pow(powerUp.multiplier, powerUp.purchaseCount);
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

  int calculatePowerUpCost(PowerUp powerUp) {
    return (powerUp.baseCost * pow(1.5, powerUp.purchaseCount)).toInt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
