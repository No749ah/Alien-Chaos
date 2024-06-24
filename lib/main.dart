import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/users/user.dart';
import 'cookies.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Widget> _initialPage;

  @override
  void initState() {
    super.initState();
    _initialPage = _checkForExistingUser();
  }

  Future<Widget> _checkForExistingUser() async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> users = await dbHelper.fetchUsers();
    if (users.isNotEmpty) {
      User existingUser = User.fromMap(users.first);
      return CookiesPage(user: existingUser);
    } else {
      return const UserInputPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _initialPage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return MaterialApp(
              title: 'Cookie Clicker Clone',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: snapshot.data!,
            );
          } else {
            return const CircularProgressIndicator();
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
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
      User newUser = User(name: username, cookies: 0);
      await dbHelper.insertUser(newUser.toMap());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CookiesPage(user: newUser)),
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
