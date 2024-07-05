import 'package:alien_chaos/helper/game_state.dart';
import 'package:alien_chaos/models/powerup.dart';
import 'package:alien_chaos/models/user.dart';
import 'package:alien_chaos/ui/store_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Integration test for buying a power-up', (WidgetTester tester) async {
    final gameState = GameState();

    final user = User(aliens: 1000, prestige: 0, name: 'Tester', spinDate: DateTime.now());
    gameState.user = user;

    final powerUp = PowerUp(
      baseCost: 100,
      purchaseCount: 0,
      type: 'click',
      display_name: 'Power Click',
      multiplier: 1.5,
      purchasable: 1,
      id: 1,
      name: 'Tester Item',
    );
    gameState.powerUps = [powerUp];

    await tester.pumpWidget(
      ChangeNotifierProvider<GameState>.value(
        value: gameState,
        child: MaterialApp(
          home: PowerUpShop(gameState: gameState),
        ),
      ),
    );

    expect(gameState.user!.aliens, 1000);
    expect(gameState.powerUps.first.purchaseCount, 0);

    await tester.tap(find.text('Power Click (100 Aliens)'));
    await tester.pump();

    expect(gameState.user!.aliens, 900);
    expect(gameState.powerUps.first.purchaseCount, 1);
  });
}
