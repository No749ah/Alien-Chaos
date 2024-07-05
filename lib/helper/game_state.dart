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
  final DatabaseHelper _dbHelper;

  GameState({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  User? get user => _user;

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  List<PowerUp> get powerUps => _powerUps;

  set powerUps(List<PowerUp> powerUps) {
    _powerUps = powerUps;
    notifyListeners();
  }

  Future<void> initialize() async {
    _user = await _dbHelper.fetchUser();
    _powerUps = await _dbHelper.fetchPowerUps();
    _startAlienGrowth();
    notifyListeners();
  }

  Future<void> updatePowerUpPurchaseCount(int id, int newCount) async {
    await _dbHelper.updatePowerUpPurchaseCount(id, newCount);
    _powerUps = await _dbHelper.fetchPowerUps();
    notifyListeners();
  }

  void _startAlienGrowth() {
    _timer?.cancel();
    if (calculateAliensPerSecond() > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        if (_user != null) {
          var aliensPerSecond = calculateAliensPerSecond();
          if (aliensPerSecond > 0) {
            _user!.aliens += aliensPerSecond;
            await _dbHelper.updateUser(_user);
            notifyListeners();
          }
        }
      });
    }
  }

  double calculateAliensPerSecond() {
    return calculatePowerupMultiplier(['second', 'multiplier']);
  }

  double calculateAliensPerClick() {
    var aliensPerClick = calculatePowerupMultiplier(['click', 'multiplier']);
    return aliensPerClick < 1 ? 1 * _user!.prestige : aliensPerClick;
  }

  double calculatePowerupMultiplier(List<String> powerUpTypes) {
    double multiplier = 1.0;
    bool hasChanged = false;
    for (var powerUp in _powerUps) {
      if (powerUpTypes.contains(powerUp.type) && powerUp.purchaseCount != 0) {
        hasChanged = true;
        multiplier *= getMultiplier(powerUp);
      }
    }
    return hasChanged ? multiplier : 0;
  }

  num getMultiplier(PowerUp powerUp) {
    return pow(powerUp.multiplier, powerUp.purchaseCount) *
        (user?.prestige ?? 1.0);
  }

  Future<void> executeAlienIncrement() async {
    if (_user != null) {
      double aliensPerClick = calculateAliensPerClick();
      if (aliensPerClick < 1) aliensPerClick = 1;
      _user!.aliens += aliensPerClick;
      await _dbHelper.updateUser(_user);
      notifyListeners();
    }
  }

  Future<void> updateUser(User user) async {
    await _dbHelper.updateUser(user);
    notifyListeners();
  }

  Future<void> purchasePowerUp(PowerUp powerUp) async {
    int currentCost = calculatePowerUpCost(powerUp);
    if (_user != null && _user!.aliens >= currentCost) {
      _user!.aliens -= currentCost;
      powerUp.purchaseCount += 1;
      await _dbHelper.updatePowerUpPurchaseCount(
          powerUp.id, powerUp.purchaseCount);
      await _dbHelper.updateUser(_user);
      notifyListeners();
      initialize();
    } else {
      throw Exception('Not enough aliens to purchase ${powerUp.display_name}');
    }
  }

  int calculatePowerUpCost(PowerUp powerUp) {
    return (powerUp.baseCost * pow(1.5, powerUp.purchaseCount)).toInt();
  }

  Future<void> setSpinDate() async {
    _user!.spinDate = DateTime.now();
    await _dbHelper.updateUser(_user);
    notifyListeners();
  }

  double calculatePrestigePoints(double totalAliens, int totalPowerUps,
      double prestigeMultiplier, double currentPrestige) {
    double basePoints =
        (log(totalAliens + 1) + totalPowerUps) * prestigeMultiplier;
    double bonusPoints = totalPowerUps * 0.25;
    num divisor = currentPrestige < 1 ? 1 : currentPrestige;
    return ((basePoints + bonusPoints) / divisor);
  }

  Future<bool> prestige() async {
    if (_user != null) {
      bool succesfulSave = true;
      double totalAliens = _user!.aliens;
      int totalPowerUps =
          powerUps.fold(0, (sum, powerUp) => sum + powerUp.purchaseCount);
      double prestigeMultiplier = 0.01;
      double prestigePoints = calculatePrestigePoints(
          totalAliens, totalPowerUps, prestigeMultiplier, _user!.prestige);

      _user!.prestige += prestigePoints;
      _user!.aliens = 0;

      for (var powerUp in powerUps) {
        powerUp.purchaseCount = 0;
        try {
          await _dbHelper.updatePowerUp(powerUp);
        } catch (e) {
          succesfulSave = false;
        }
      }
      try {
        await _dbHelper.updateUser(_user);
      } catch (e) {
        succesfulSave = false;
      }
      notifyListeners();
      return succesfulSave;
    }
    return false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
