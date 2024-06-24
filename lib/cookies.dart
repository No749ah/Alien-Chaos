import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/users/user.dart';

class CookiesPage extends StatefulWidget {
  final User user;

  const CookiesPage({Key? key, required this.user}) : super(key: key);

  @override
  _CookiesPageState createState() => _CookiesPageState();
}

class _CookiesPageState extends State<CookiesPage> {
  late DatabaseHelper dbHelper;
  late User _user;
  int _cookies = 0;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    _user = widget.user;
    _cookies = _user.cookies;
  }

  Future<void> _incrementCookies() async {
    try {
      setState(() {
        _cookies++;
      });
      _user = _user.copyWith(cookies: _cookies);
      await dbHelper.updateUser(_user.toMap());
    } catch (e) {
      print('Error incrementing cookies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${_user.name}'),
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
                // ignore: undefined_named_parameter
                foregroundColor: Colors.white,
                // ignore: undefined_named_parameter
                backgroundColor: Colors.blue,
              ),
              child: const Text('Click me!'),
            ),
          ],
        ),
      ),
    );
  }
}
