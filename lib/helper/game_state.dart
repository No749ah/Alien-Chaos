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
      notifyListeners(); // Notify listeners after fetching the user
    }
  }

  Future<void> _fetchPowerUps() async {
    List<Map<String, dynamic>> powerUpData = await _dbHelper.fetchPowerUps();
    _powerUps = powerUpData.map((data) => PowerUp.fromMap(data)).toList();
    notifyListeners(); // Notify listeners after fetching power-ups
  }

  void _startAlienGrowth() {
    _timer?.cancel();
    int aliensPerSecond = calculateAliensPerSecond();

    if (aliensPerSecond > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        if (_user != null) {
          _user!.aliens += aliensPerSecond;
          await _dbHelper.updateUser(_user!.toMap());
          notifyListeners(); // Notify listeners after updating aliens count
        }
      });
    }
  }

  int calculateAliensPerSecond() {
    int baseAliensPerSecond = 1;
    for (var powerUp in _powerUps) {
      if (powerUp.type == 'second') {
        baseAliensPerSecond += powerUp.value;
      }
    }
    double multiplier = 1.0;
    for (var powerUp in _powerUps) {
      if (powerUp.type == 'second') {
        multiplier *= pow(1.3, powerUp.purchaseCount);
      }
    }
    return ((baseAliensPerSecond * multiplier) -1).toInt();
  }

  int calculateAliensPerClick() {
    int baseAliensPerClick = 0;
    for (var powerUp in _powerUps) {
      if (powerUp.type == 'click') {
        baseAliensPerClick += powerUp.value;
      }
    }
    double multiplier = 1.0;
    for (var powerUp in _powerUps) {
      if (powerUp.type == 'click') {
        multiplier *= pow(1.2, powerUp.purchaseCount);
      }
    }
    return (baseAliensPerClick * multiplier).toInt();
  }

  num getFinalMultiplier(PowerUp powerUp) {
    if (powerUp.type == 'click') {
      return pow(1.2, powerUp.purchaseCount);
    } else if (powerUp.type == 'second') {
      return pow(1.3, powerUp.purchaseCount);
    }
    return 1.0;
  }

  Future<void> incrementAliens() async {
    if (_user != null) {
      int aliensPerClick = calculateAliensPerClick();
      _user!.aliens += aliensPerClick;
      await _dbHelper.updateUser(_user!.toMap());
      notifyListeners(); // Notify listeners after incrementing aliens
    }
  }

  Future<void> purchasePowerUp(PowerUp powerUp) async {
    int currentCost = calculatePowerUpCost(powerUp);
    if (_user != null && _user!.aliens >= currentCost) {
      _user!.aliens -= currentCost;
      powerUp.purchaseCount += 1;
      await _dbHelper.updatePowerUpPurchaseCount(powerUp.id, powerUp.purchaseCount);
      await _dbHelper.updateUser(_user!.toMap());
      notifyListeners(); // Notify listeners after purchasing power-up
    } else {
      // Display a message if there are not enough aliens
      print('Not enough aliens to purchase ${powerUp.name}');
      throw Exception('Not enough aliens to purchase ${powerUp.name}');
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