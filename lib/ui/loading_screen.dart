import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String loadingText;

  const LoadingScreen({Key? key, this.loadingText = "Loading, please wait..."}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/loading_screen.png',
            fit: BoxFit.cover,
          ),
          Center(
            child: Text(
              loadingText,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
