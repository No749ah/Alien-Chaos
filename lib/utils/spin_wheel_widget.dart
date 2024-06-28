import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:rxdart/rxdart.dart';

import '../models/reward.dart';

class SpinWheelWidget extends StatefulWidget {
  final StreamController<int> controller;
  final Function(Reward) onSpinComplete;
  final Future<List<Reward>> Function() fetchRewards;

  const SpinWheelWidget({
    Key? key,
    required this.controller,
    required this.onSpinComplete,
    required this.fetchRewards,
  }) : super(key: key);

  @override
  State<SpinWheelWidget> createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheelWidget> {
  final selected = BehaviorSubject<int>();
  List<Reward> items = [];
  int rewards = 0;

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.stream.listen((event) {
      selected.add(event);
    });
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    items = await widget.fetchRewards();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? CircularProgressIndicator()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 300,
          child: FortuneWheel(
            selected: selected.stream,
            animateFirst: false,
            items: [
              for (int i = 0; i < items.length; i++)
                ...<FortuneItem>{
                  FortuneItem(child: Text(items[i].name)),
                },
            ],
            onAnimationEnd: () {
              setState(() {
                rewards = selected.value;
              });
              widget.onSpinComplete(items[rewards]);
            },
          ),
        ),
      ],
    );
  }
}