import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/users/user.dart';
import 'cookies.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookie Clicker Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserInputPage(),
    );
  }
}

class UserInputPage extends StatefulWidget {
  const UserInputPage({Key? key}) : super(key: key);

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
  }

  Future<void> _createUser() async {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      User user = User(name: username, cookies: 0);
      await dbHelper.insertUser(user.toMap());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CookiesPage(user: user)),
      );
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
            ElevatedButton(
              onPressed: _createUser,
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}
