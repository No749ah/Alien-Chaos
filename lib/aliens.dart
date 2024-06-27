import 'package:flutter/material.dart';
import 'package:alien_chaos/db/database_helper.dart';
import 'package:alien_chaos/helper/alien_growth_helper.dart';
import 'package:alien_chaos/models/users/user.dart';
import 'package:alien_chaos/store.dart';

class AliensPage extends StatefulWidget {
  final User user;

  const AliensPage({Key? key, required this.user}) : super(key: key);

  @override
  _AliensPageState createState() => _AliensPageState();
}

class _AliensPageState extends State<AliensPage> {
  late DatabaseHelper dbHelper;
  late User _user;
  int _aliens = 0;
  bool _updatingAliens = false; // Track if an update is in progress

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    _user = widget.user;
    _aliens = _user.aliens;
    AlienGrowthHelper.initializePowerUps(_user, _updateAliens, () => mounted);
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

  Future<void> _incrementAliens() async {
    if (_updatingAliens) return; // Prevent multiple updates at the same time
    setState(() {
      _updatingAliens = true;
    });
    try {
      await AlienGrowthHelper.incrementAliens(_user, _updateAliens);
    } catch (e) {
      print('Error incrementing aliens: $e');
    } finally {
      setState(() {
        _updatingAliens = false;
      });
    }
  }

  Future<void> _navigateToPowerUpShop() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PowerUpShop(user: _user)),
    );
    if (updatedUser != null) {
      setState(() {
        _user = updatedUser;
        _aliens = _user.aliens;
      });
      AlienGrowthHelper.initializePowerUps(_user, _updateAliens, () => mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${_user.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.shop),
            onPressed: _navigateToPowerUpShop,
          ),
        ],
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
            InkWell(
              onTap: _incrementAliens,
              child: CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/alien.png'), // Your round image asset
              ),
            ),
          ],
        ),
      ),
    );
  }
}
