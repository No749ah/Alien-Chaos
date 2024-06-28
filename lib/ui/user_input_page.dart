import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import 'aliens_page.dart';

class UserInputPage extends StatefulWidget {
  final User? user;

  const UserInputPage({Key? key, this.user}) : super(key: key);

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
      if (widget.user == null) {
        // Create new user
        User newUser = User(name: username, aliens: 0);
        await dbHelper.insertUser(newUser.toMap());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AliensPage(user: newUser)),
        );
      } else {
        // Update existing user
        User updatedUser = User(
          id: widget.user!.id, // Ensure the user has an id
          name: username,
          aliens: widget.user!.aliens,
        );
        await dbHelper.updateUser(updatedUser.toMap());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AliensPage(user: updatedUser)),
        );
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
                backgroundImage: AssetImage('assets/alien.png'), // Your round image asset
              ),
            ),
          ],
        ),
      ),
    );
  }
}
