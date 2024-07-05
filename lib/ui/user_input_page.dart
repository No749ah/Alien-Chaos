import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import 'aliens_page.dart';

class UserInputPage extends StatefulWidget {
  final User? user;
  final RouteObserver<PageRoute> routeObserver;
  final VoidCallback onUserUpdated;

  const UserInputPage(
      {Key? key,
      this.user,
      required this.routeObserver,
      required this.onUserUpdated})
      : super(key: key);

  @override
  _UserInputPageState createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage> with RouteAware {
  final TextEditingController _usernameController = TextEditingController();
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;

    initializePage();
  }

  void initializePage() {
    if (widget.user != null) {
      _usernameController.text = widget.user!.name;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver
        .subscribe(this, ModalRoute.of(context)! as PageRoute<dynamic>);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    initializePage();
  }

  Future<void> _saveUser() async {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      var user = await dbHelper.fetchUser();
      if (user != null) {
        user.name = username;
        await dbHelper.updateUser(user);
        widget.onUserUpdated();
        Navigator.pop(context, user);
      } else {
        User newUser = User(
            name: username,
            aliens: 0,
            spinDate: DateTime(2000, 1, 1),
            prestige: 1);
        await dbHelper.insertUser(newUser);
        widget.onUserUpdated();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AliensPage(
                    user: newUser,
                    routeObserver: widget.routeObserver,
                  )),
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
                backgroundImage: AssetImage('assets/images/alien.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
