import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

class UserInputPage extends StatefulWidget {
  final User? user;
  final RouteObserver<PageRoute> routeObserver;
  final VoidCallback onUserUpdated;

  const UserInputPage({Key? key, this.user, required this.routeObserver, required this.onUserUpdated}) : super(key: key);

  @override
  _UserInputPageState createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage> {
  final TextEditingController _usernameController = TextEditingController();
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    if (widget.user != null) {
      _usernameController.text = widget.user!.name;
    }
  }

  Future<void> _saveUser() async {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      List<Map<String, dynamic>> users = await dbHelper.fetchUsers();
      if (users.isNotEmpty) {
        Map<String, dynamic> existingUser = Map<String, dynamic>.from(users.first);
        existingUser['name'] = username;

        await dbHelper.updateUser(existingUser);
        User updatedUser = User.fromMap(existingUser);
        widget.onUserUpdated();
        Navigator.pop(context, updatedUser);
      } else {
        User newUser = User(name: username, aliens: 0, spinDate: DateTime(2000, 1, 1), prestige: 1);
        await dbHelper.insertUser(newUser.toMap());
        widget.onUserUpdated();
        Navigator.pop(context, newUser);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Username'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: _saveUser,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/alien.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
