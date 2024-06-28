import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/game_state.dart';
import '../utils/number_formatter.dart';
import '../models/powerup.dart';
import '../models/user.dart';
import 'store_page.dart';
import 'user_input_page.dart';

class AliensPage extends StatefulWidget {
  final User user;

  const AliensPage({Key? key, required this.user}) : super(key: key);

  @override
  _AliensPageState createState() => _AliensPageState();
}

class _AliensPageState extends State<AliensPage> {
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _gameState.initialize();
  }

  @override
  void dispose() {
    _gameState.dispose();
    super.dispose();
  }

  Future<void> _incrementAliens() async {
    await _gameState.incrementAliens();
  }

  Future<void> _navigateToPowerUpShop() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PowerUpShop(gameState: _gameState)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _navigateToUserInputPage() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserInputPage(user: widget.user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  String _formatPowerUpType(PowerUp powerUp, GameState gameState) {
    num multi = gameState.getFinalMultiplier((powerUp));
    if (powerUp.type == 'click') {
      return '${(reducedFormatNumber(double.parse((multi).toStringAsFixed(2))))} x Click Multiplier';
    } else if (powerUp.type == 'second') {
      return '${(reducedFormatNumber(double.parse((multi- 1).toStringAsFixed(2))))} x Aliens / Second';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameState,
      child: Consumer<GameState>(
        builder: (context, gameState, child) {
          if (gameState.user == null) {
            return const CircularProgressIndicator(); // Show loading indicator while initializing
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Welcome, ${gameState.user!.name}'),
              actions: [
                IconButton(
                  icon: Icon(Icons.shop),
                  onPressed: _navigateToPowerUpShop,
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: _navigateToUserInputPage,
                ),
              ],
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
                  InkWell(
                    onTap: _incrementAliens,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage('assets/alien.png'),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Type')),
                        ],
                        rows: gameState.powerUps.map((powerUp) {
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(Text('${powerUp.purchaseCount}')),
                              DataCell(Text(powerUp.display_name)),
                              DataCell(Text(_formatPowerUpType(powerUp, gameState))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
