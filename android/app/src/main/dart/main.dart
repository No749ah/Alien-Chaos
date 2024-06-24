import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './db/database_helper.dart';
import './models/users/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter SQLite Demo',
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

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
  }

  Future<void> _insertUser() async {
    User user = User(name: 'Alice', cookies: 3000);
    await dbHelper.insertUser(user.toMap());
  }

  Future<void> _fetchUsers() async {
    final users = await dbHelper.fetchUsers();
    for (var user in users) {
      if (kDebugMode) {
        print(User.fromMap(user));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter SQLite Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _insertUser,
              child: const Text('Insert User'),
            ),
            ElevatedButton(
              onPressed: _fetchUsers,
              child: const Text('Fetch Users'),
            ),
          ],
        ),
      ),
    );
  }
}
