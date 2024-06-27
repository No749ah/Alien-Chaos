import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import '../helper/game_state.dart';
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
  late ShakeDetector _shakeDetector;
  final StreamController<int> controller = StreamController<int>();

  @override
  void initState() {
    super.initState();
    _user = widget.gameState.user!;
    _shakeDetector = ShakeDetector.autoStart(onPhoneShake: _extendSpin);
  }

  @override
  void dispose() {
    _shakeDetector.stopListening();
    controller.close();
    super.dispose();
  }

  void _onSpinComplete(String reward) async {
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
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
    });
    final randomValue = Random().nextInt(4);
    controller.add(randomValue);
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
