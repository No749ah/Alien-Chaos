import 'package:alien_chaos/helper/game_state.dart';
import 'package:alien_chaos/models/powerup.dart';
import 'package:alien_chaos/models/user.dart';
import 'package:alien_chaos/ui/store_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Integration test for making a prestige', (WidgetTester tester) async {
    final gameState = GameState();
    final user = User(aliens: 20000, prestige: 1, name: 'Tester', spinDate: DateTime.now());
    gameState.user = user;
    final powerUp1 = PowerUp(id: 1, baseCost: 100, display_name: 'powerup1', name: 'powerup1', multiplier: 10, type: 'second', purchasable: 1, purchaseCount: 10);
    final powerUp2 = PowerUp(id: 2, baseCost: 12, display_name: 'powerup2', name: 'powerup2', multiplier: 4, type: 'click', purchasable: 1, purchaseCount: 10);
    gameState.powerUps = [powerUp1, powerUp2];

    await tester.pumpWidget(
      ChangeNotifierProvider<GameState>.value(
        value: gameState,
        child: MaterialApp(
          home: PowerUpShop(gameState: gameState),
        ),
      ),
    );

    await tester.tap(find.text('Prestige'));
    await tester.pump();

    expect(gameState.user!.aliens, 0);
    expect(gameState.user!.prestige, 6.299035375512862);
    expect(gameState.powerUps.first.purchaseCount, 0);
  });
}
