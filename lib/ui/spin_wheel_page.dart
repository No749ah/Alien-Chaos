import 'dart:async';
import 'dart:math';
import 'package:alien_chaos/helper/timeHelper.dart';
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
  String _errorMessage = '';
  DateTime _lastErrorMessageTime = DateTime.now().subtract(
      Duration(seconds: 30));
  final StreamController<int> controller = StreamController<int>();
  late List<Reward> _rewards;

  @override
  void initState() {
    super.initState();
    _user = widget.gameState.user!;
    _rewards = [];

    ShakeDetector.autoStart(onPhoneShake: () {
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
        name: (_user.aliens * multiplier).round().toString() + ' Aliens',
        aliens: _user.aliens);
  }

  Future<Reward> setupPowerUpReward(PowerUp powerUp) async {
    return Reward(name: powerUp.display_name, powerupId: powerUp.id);
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

      var powerUps = widget.gameState.powerUps;
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
    _stopVibration();
    setState(() {
      _result = reward.name;
      _isSpinning = false;
    });

    if (reward.powerupId != 0) {
      await _applyPowerup(reward.powerupId);
    } else {
      _user.aliens += reward.aliens;
      await widget.gameState.updateUser(_user);
    }
  }

  setAccelerationSamplingPeriod() {
    return;
  }

  Future<void> _applyPowerup(int id) async {
    var powerUps = widget.gameState.powerUps;
    var powerUp = powerUps.firstWhere((pu) => pu.id == id);
    powerUp.purchaseCount += 1;
    await widget.gameState
        .updatePowerUpPurchaseCount(powerUp.id, powerUp.purchaseCount);
    await widget.gameState.updateUser(_user);
  }

  void _startSpinning() {
    DateTime now = DateTime.now();
    if (_isSpinning || !timeHelper.isPreviousDay(_user.spinDate)) {
      if (now
          .difference(_lastErrorMessageTime)
          .inSeconds > 30) {
        setState(() {
          _lastErrorMessageTime = now;
          _errorMessage =
          'You have already spun today. Please come back tomorrow! Next spin available at: ${_user
              .spinDate.add(Duration(days: 1)).toLocal()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    final randomValue = Random().nextInt(_rewards.length);
    controller.add(randomValue);
    widget.gameState.setSpinDate();
    _startVibration();
  }

  void _startVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != null && hasVibrator) {
      Vibration.vibrate();
    }
  }

  void _stopVibration() {
    Vibration.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spin Test'),
      ),
      body: Center(
        child: GestureDetector(
          onHorizontalDragDown: (details) => _startSpinning(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinWheelWidget(
                onSpinComplete: (reward) => _onSpinComplete(reward),
                controller: controller,
                fetchRewards: fetchRewards,
              ),
              SizedBox(height: 20),
              Text('Result: $_result'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: timeHelper.isPreviousDay(_user.spinDate)
                    ? _startSpinning
                    : null,
                child: Text('Spin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}