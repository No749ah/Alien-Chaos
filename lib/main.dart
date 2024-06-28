import 'package:alien_chaos/ui/aliens_page.dart';
import 'package:alien_chaos/ui/user_input_page.dart';
import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Widget> _initialPage;
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
      return AliensPage(user: existingUser, routeObserver: routeObserver);
    } else {
      return UserInputPage(routeObserver: routeObserver);
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
              title: 'Alien Chaos',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: snapshot.data!,
              navigatorObservers: [routeObserver],
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
