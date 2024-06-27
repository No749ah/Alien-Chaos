import 'dart:math'; // Import the dart:math library for pow function
import 'package:alien_chaos/aliens.dart';
import 'package:flutter/material.dart';
import 'package:alien_chaos/db/database_helper.dart';
import 'package:alien_chaos/helper/alien_growth_helper.dart';
import 'package:alien_chaos/models/users/powerup.dart';
import 'package:alien_chaos/models/users/user.dart';

class PowerUpShop extends StatefulWidget {
  final User user;

  const PowerUpShop({Key? key, required this.user}) : super(key: key);

  @override
  _PowerUpShopState createState() => _PowerUpShopState();
}

class _PowerUpShopState extends State<PowerUpShop> {
  late DatabaseHelper dbHelper;
  late User _user;
  int _aliens = 0;
  List<PowerUp> _availablePowerUps = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    _user = widget.user;
    _aliens = _user.aliens;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    List<Map<String, dynamic>> users = await dbHelper.fetchUsers();
    if (users.isNotEmpty) {
      setState(() {
        _user = User.fromMap(users.first);
        _aliens = _user.aliens;
      });
      _initializePowerUps();
      AlienGrowthHelper.initializePowerUps(_user, _updateAliens, () => mounted);
    }
  }

  Future<void> _navigateToAliens() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AliensPage(user: _user)),
    );
    if (updatedUser != null) {
      setState(() {
        _user = updatedUser;
        _aliens = _user.aliens;
      });
      AlienGrowthHelper.initializePowerUps(_user, _updateAliens, () => mounted);
    }
  }

  void _updateAliens(int newAliens) {
    if (mounted) {
      setState(() {
        _aliens = newAliens;
        _user = _user.copyWith(aliens: newAliens); // Update the user object with new aliens count
      });
    }
  }

  @override
  void dispose() {
    AlienGrowthHelper.stopAlienGrowth();
    super.dispose();
  }

  Future<void> _initializePowerUps() async {
    AlienGrowthHelper.stopAlienGrowth();
    _availablePowerUps = [];
    List<Map<String, dynamic>> powerUpData = await dbHelper.fetchPowerUps();

    // Debug print statements to check fetched data
    print('Fetched Power-Ups: $powerUpData');

    setState(() {
      _availablePowerUps = powerUpData.map((data) {
        return PowerUp(
          data['name'] as String,
          data['type'] as String,
          data['value'] ?? 0, // Ensure value is not null
          data['cost'] ?? 0,  // Ensure cost is not null
          data['purchase_count'] ?? 0, // Ensure purchase_count is not null
          data['id'] as int,
        );
      }).toList();
    });

    // Start the alien growth
    AlienGrowthHelper.startAlienGrowth(_user, _updateAliens, () => mounted);
  }

  int _calculateCost(int baseCost, int purchaseCount) {
    return (baseCost * pow(1.5, purchaseCount)).toInt();
  }

  Future<void> _purchasePowerUp(PowerUp powerUp) async {
    int currentCost = _calculateCost(powerUp.baseCost, powerUp.purchaseCount);
    if (_aliens >= currentCost) {
      setState(() {
        _aliens -= currentCost;
        powerUp.purchaseCount += 1;
      });
      await dbHelper.updatePowerUpPurchaseCount(powerUp.id, powerUp.purchaseCount);
      _updateAliens(_aliens); // Update aliens after purchase
      _user = _user.copyWith(aliens: _aliens);
      await dbHelper.updateUser(_user.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${powerUp.name} purchased!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough aliens!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToAliens();
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
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
                'Aliens: $_aliens',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _availablePowerUps.length,
                  itemBuilder: (context, index) {
                    final powerUp = _availablePowerUps[index];
                    int currentCost = _calculateCost(powerUp.baseCost, powerUp.purchaseCount);
                    return ListTile(
                      title: Text('${powerUp.name} (${currentCost} aliens)'),
                      subtitle: Text('Adds ${powerUp.value} ${powerUp.type == "click" ? "per click" : "per second"}'),
                      onTap: () => _purchasePowerUp(powerUp),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
