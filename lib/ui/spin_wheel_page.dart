import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:vibration/vibration.dart';
import '../helper/game_state.dart';
import '../models/powerup.dart';
import '../models/reward.dart';
import '../models/user.dart';
import '../utils/spin_wheel_widget.dart';

class SpinWheelPage extends StatefulWidget {
  final GameState gameState;

  const SpinWheelPage({Key? key, required this.gameState}) : super(key: key);

  @override
  _SpinWheelPageState createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage> {
  late User _user;
  bool _isSpinning = false;
  String _result = '';
  final StreamController<int> controller = StreamController<int>();

  @override
  void initState() {
    super.initState();
    _user = widget.gameState.user!;
    _rewards = [];

    ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
      _startSpinning();
    });
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  Future<Reward> setupReward(double multiplier) async {
    return Reward(
        name: (_user.aliens * multiplier).toString() + ' Aliens',
        aliens: _user.aliens);
  }

  Future<Reward> setupPowerUpReward(PowerUp powerUp) async {
    return Reward(name: powerUp.name, powerupId: powerUp.id);
  }

  static PowerUp randomPowerUp(List<PowerUp> powerUps) {
    final randomIndex = Random().nextInt(powerUps.length);
    return powerUps[randomIndex];
  }

  Future<List<Reward>> fetchRewards() async {
    if (_rewards.isEmpty) {
      _rewards.add(await setupReward(0.5));
      _rewards.add(await setupReward(1.5));
      _rewards.add(await setupReward(2));

      var powerUps = await widget.gameState.fetchPowerUps();
      _rewards.add(
          await setupPowerUpReward(powerUps.firstWhere((pu) => pu.id == 900)));

      var purchasedPowerUp =
          powerUps.where((pu) => pu.purchaseCount >= 0).toList();
      _rewards.add(await setupPowerUpReward(randomPowerUp(purchasedPowerUp)));
      _rewards.add(await setupPowerUpReward(randomPowerUp(purchasedPowerUp)));
      _rewards.add(await setupPowerUpReward(randomPowerUp(purchasedPowerUp)));
    }
    return _rewards;
  }

  void _onSpinComplete(Reward reward) async {
    setState(() {
      _result = reward;
      _isSpinning = false;
    });

    // Apply the reward
    if (reward == 'Multiplier') {
      await _applyMultiplier();
    } else {
      _user.aliens += 100; // Add 100 aliens as a reward
      await widget.gameState.updateUser(_user.toMap());
    }
  }

  Future<void> _applyMultiplier() async {
    var powerUps = await widget.gameState.fetchPowerUps();
    var multiplierPowerUp = powerUps.firstWhere((pu) => pu.name == 'Daily Multiplier');
    multiplierPowerUp.purchaseCount += 1;
    await widget.gameState.updatePowerUpPurchaseCount(multiplierPowerUp.id, multiplierPowerUp.purchaseCount);
    await widget.gameState.updateUser(_user.toMap());
  }

  void _startSpinning() {
    if (_isSpinning || _user.spinDate.day >= DateTime.now().day) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'You have already spun today. Please come back tomorrow!')),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    final randomValue = Random().nextInt(_rewards.length);
    controller.add(randomValue);
    widget.gameState.setSpinDate();
  }

  void _startVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != null && hasVibrator) {
      Vibration.vibrate();
    } else {
      print('Device does not have a vibrator.');
    }
  }

  void _stopVibration() {
    Vibration.cancel();
  }

  void _extendSpin() {
    if (_isSpinning) {
      setState(() {
        // Extend spin by increasing spin velocity or adding more spins
        _result = 'Extended Spin!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spin Wheel'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinWheelWidget(onSpinComplete: _onSpinComplete, controller: controller),
            SizedBox(height: 20),
            Text('Result: $_result'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startSpinning,
              child: Text('Spin'),
            ),
          ],
        ),
      ),
    );
  }
}
