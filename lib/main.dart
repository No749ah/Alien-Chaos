import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/users/user.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
    print('DatabaseHelper initialized');
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final users = await dbHelper.fetchUsers();
      print('Users fetched: $users');
      if (users.isNotEmpty) {
        setState(() {
          _user = User.fromMap(users.first);
          _cookies = _user!.cookies;
          print('User loaded: $_user');
        });
      } else {
        User user = User(name: 'Player', cookies: 0);
        await dbHelper.insertUser(user.toMap());
        print('New user inserted');
        _loadUser();
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> _incrementCookies() async {
    try {
      setState(() {
        _cookies++;
        print('Cookies incremented: $_cookies');
      });
      _user = _user?.copyWith(cookies: _cookies);
      if (_user != null) {
        await dbHelper.updateUser(_user!.toMap());
        print('User updated: $_user');
      }
    } catch (e) {
      print('Error incrementing cookies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building widget tree');
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
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementCookies,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
              ),
              child: const Text('Click me!'),
            ),
          ],
        ),
      ),
    );
  }
}
