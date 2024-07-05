import 'package:alien_chaos/helper/game_state.dart';
import 'package:alien_chaos/models/powerup.dart';
import 'package:alien_chaos/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final GameState gameState = GameState();

  group('Alien Calculation Tests', () {
    test("Test Multiplier", () {
      gameState.user = User(name: "Test-User", aliens: 123, prestige: 1, spinDate: DateTime(0000, 1, 1));

      PowerUp powerUp = PowerUp(baseCost: 100, purchaseCount: 3, id: 1, name: 'Test', display_name: 'Test1', type: 'second', multiplier: 1.2);
      expect(gameState.getMultiplier(powerUp), 1.728);
    });

    test("Test Multiplier with Prestige", () {
      gameState.user = User(name: "Test-User", aliens: 123, prestige: 1.5, spinDate: DateTime(0000, 1, 1));

      PowerUp powerUp = PowerUp(baseCost: 100, purchaseCount: 3, id: 1, name: 'Test', display_name: 'Test1', type: 'second', multiplier: 1.2);
      expect(gameState.getMultiplier(powerUp), 2.592);
    });

    test("Test No Multiplier with Prestige", () {
      gameState.user = User(name: "Test-User", aliens: 123, prestige: 1.5, spinDate: DateTime(0000, 1, 1));

      PowerUp powerUp = PowerUp(baseCost: 100, purchaseCount: 3, id: 1, name: 'Test', display_name: 'Test1', type: 'second', multiplier: 0);
      expect(gameState.getMultiplier(powerUp), 0);
    });
  });
}