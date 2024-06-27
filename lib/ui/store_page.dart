import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helper/game_state.dart';
import '../models/powerup.dart';
import '../utils/number_formatter.dart';  // Import the number formatter

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
    Navigator.pop(context); // Return to the previous screen (AliensPage)
  }

  int _calculateIncrease(PowerUp powerUp) {
    int currentValue = powerUp.type == 'click'
        ? _gameState.calculateAliensPerClick()
        : _gameState.calculateAliensPerSecond();

    powerUp.purchaseCount += 1;
    int newValue = powerUp.type == 'click'
        ? _gameState.calculateAliensPerClick()
        : _gameState.calculateAliensPerSecond();
    powerUp.purchaseCount -= 1; // revert the change

    return newValue - currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToAliens();
        return false; // Prevent default back button behavior
      },
      child: ChangeNotifierProvider.value(
        value: _gameState,
        child: Consumer<GameState>(
          builder: (context, gameState, child) {
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
                      'Aliens: ${slightReducedFormatNumber(gameState.user!.aliens)}',  // Format the alien count
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: gameState.powerUps.length,
                        itemBuilder: (context, index) {
                          final powerUp = gameState.powerUps[index];
                          int currentCost = gameState.calculatePowerUpCost(powerUp);
                          int increase = _calculateIncrease(powerUp);

                          return ListTile(
                            title: Text('${powerUp.name} (${reducedFormatNumber(currentCost)} aliens)'),  // Format the cost
                            subtitle: Text(
                              'Adds ${powerUp.value} ${powerUp.type == "click" ? "per click" : "per second"}\n'
                                  'Increase: ${reducedFormatNumber(increase)} ${powerUp.type == "click" ? "per click" : "per second"}',  // Format the increase
                            ),
                            onTap: () async {
                              try {
                                await gameState.purchasePowerUp(powerUp);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                          );
                        },
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
