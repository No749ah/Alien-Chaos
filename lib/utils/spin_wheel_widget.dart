// spin_wheel_widget.dart

import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:async';

class SpinWheelWidget extends StatefulWidget {
  final Function(String) onSpinComplete;
  final StreamController<int> controller;

  SpinWheelWidget({required this.onSpinComplete, required this.controller});

  @override
  _SpinWheelWidgetState createState() => _SpinWheelWidgetState();
}

class _SpinWheelWidgetState extends State<SpinWheelWidget> {
  final List<String> rewards = ['Multiplier', 'Aliens', 'Aliens', 'Multiplier'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FortuneWheel(
          selected: widget.controller.stream,
          items: [
            for (var reward in rewards) FortuneItem(child: Text(reward)),
          ],
          onAnimationEnd: () async {
            final selected = await widget.controller.stream.last;
            widget.onSpinComplete(rewards[selected]);
          },
        ),
        ElevatedButton(
          onPressed: () {
            final randomValue = Random().nextInt(rewards.length);
            widget.controller.add(randomValue);
          },
          child: Text('Spin'),
        ),
      ],
    );
  }
}
