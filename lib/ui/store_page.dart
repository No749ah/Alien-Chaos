import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helper/game_state.dart';
import '../models/powerup.dart';
import '../utils/number_formatter.dart';

class PowerUpShop extends StatefulWidget {
  final GameState gameState;

  const PowerUpShop({Key? key, required this.gameState}) : super(key: key);

  @override
  _PowerUpShopState createState() => _PowerUpShopState();
}

class _PowerUpShopState extends State<PowerUpShop> {
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
  }

  Future<void> _navigateToAliens() async {
    Navigator.pop(context);
  }

  double _calculateIncrease(PowerUp powerUp) {
    double currentValue = (powerUp.type == 'click'
        ? _gameState.calculateAliensPerClick()
        : _gameState.calculateAliensPerSecond());

    powerUp.purchaseCount += 1;
    double newValue = powerUp.type == 'click'
        ? _gameState.calculateAliensPerClick()
        : _gameState.calculateAliensPerSecond();
    powerUp.purchaseCount -= 1;

    return newValue - currentValue;
  }

  double _calculatePrestigeMultiplier() {
    int totalAliens = _gameState.user!.aliens;
    int totalPowerUps = _gameState.powerUps.fold(0, (sum, powerUp) => sum + powerUp.purchaseCount);
    double prestigeMultiplier = 0.1;

    return _gameState.calculatePrestigePoints(totalAliens, totalPowerUps, prestigeMultiplier, (_gameState.user!.prestige));
  }

  Future<void> _performPrestige() async {
    await _gameState.prestige();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Prestige activated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToAliens();
        return false;
      },
      child: ChangeNotifierProvider.value(
        value: _gameState,
        child: Consumer<GameState>(
          builder: (context, gameState, child) {
            double prestigeMultiplier = _calculatePrestigeMultiplier();
            List<PowerUp> purchasablePowerUps = gameState.powerUps.where((powerUp) => powerUp.purchasable == 1).toList();

            return Scaffold(
              appBar: AppBar(
                title: Text('Power-Up Shop'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _navigateToAliens,
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Aliens: ${slightReducedFormatNumber(gameState.user!.aliens)}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: purchasablePowerUps.length,
                        itemBuilder: (context, index) {
                          final powerUp = purchasablePowerUps[index];
                          int currentCost = gameState.calculatePowerUpCost(powerUp);
                          double increase = _calculateIncrease(powerUp);
                          bool canAfford = gameState.user!.aliens >= currentCost;

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: canAfford ? Colors.white : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                '${powerUp.display_name} (${reducedFormatNumber(currentCost)} Aliens)',
                                style: TextStyle(
                                  color: canAfford ? Colors.black : Colors.grey,
                                ),
                              ),
                              subtitle: Text(
                                'Multiplies ${powerUp.multiplier}x ${powerUp.type == "click" ? "clicks" : "per second"}\n'
                                    'Increase: ${reducedFormatNumber(increase)} ${powerUp.type == "click" ? "per click" : "per second"}',
                                style: TextStyle(
                                  color: canAfford ? Colors.black : Colors.grey,
                                ),
                              ),
                              onTap: canAfford
                                  ? () async {
                                try {
                                  await gameState.purchasePowerUp(powerUp);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${prestigeMultiplier.toStringAsFixed(2)}x Multiplier with Prestige',
                            style: TextStyle(fontSize: 24, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _performPrestige,
                            child: Text('Prestige'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
