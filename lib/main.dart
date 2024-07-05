import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'helper/notification.dart';
import 'models/user.dart';
import 'ui/aliens_page.dart';
import 'ui/user_input_page.dart';
import 'ui/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  var notificationController = NotificationController();
  await notificationController.initialize();

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
    _initialPage = _initializeApp();
  }

  Future<Widget> _initializeApp() async {
    await Future.delayed(Duration(seconds: 3));

    final dbHelper = DatabaseHelper.instance;
    User? user = await dbHelper.fetchUser();
    if (user != null) {
      return AliensPage(user: user, routeObserver: routeObserver);
    } else {
      return UserInputPage(
        routeObserver: routeObserver,
        onUserUpdated: () {
          setState(() {
            _initialPage = _initializeApp();
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alien Chaos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [routeObserver],
      home: FutureBuilder<Widget>(
        future: _initialPage,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              return const LoadingScreen(loadingText: "Error loading data.");
            }
          } else {
            return const LoadingScreen();
          }
        },
      ),
    );
  }
}
