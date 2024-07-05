import 'package:alien_chaos/helper/game_state.dart';
import 'package:alien_chaos/models/powerup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final gameState = GameState();

  test('Calculate power up cost after multiple purchases', () {
    PowerUp powerUp = PowerUp(baseCost: 100, purchaseCount: 3, id: 1, name: 'Test', display_name: 'Test1', type: 'second', multiplier: 1.2);
    expect(gameState.calculatePowerUpCost(powerUp), 337);
  });

  test('Calculate prestige points with higher current prestige reducing the points', () {
    double totalAliens = 1000;
    int totalPowerUps = 10;
    double prestigeMultiplier = 2.0;
    double currentPrestige = 2.0;
    expect(gameState.calculatePrestigePoints(totalAliens, totalPowerUps, prestigeMultiplier, currentPrestige), closeTo(18.15875477931522, 1e-9));
  });
}
