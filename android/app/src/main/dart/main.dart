import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/users/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Cookie Clicker Clone',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseHelper dbHelper;
  User? _user;
  int _cookies = 0;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final users = await dbHelper.fetchUsers();
    if (users.isNotEmpty) {
      setState(() {
        _user = User.fromMap(users.first);
        _cookies = _user!.cookies;
      });
    } else {
      User user = User(name: 'Player', cookies: 0);
      await dbHelper.insertUser(user.toMap());
      _loadUser();
    }
  }

  Future<void> _incrementCookies() async {
    setState(() {
      _cookies++;
    });
    _user = _user?.copyWith(cookies: _cookies);
    if (_user != null) {
      await dbHelper.updateUser(_user!.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookie Clicker Clone'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Cookies: $_cookies',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementCookies,
              child: const Text('Click me!'),
            ),
          ],
        ),
      ),
    );
  }
}