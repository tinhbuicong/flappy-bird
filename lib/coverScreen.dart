import 'package:flutter/material.dart';

class MyCoverScreen extends StatelessWidget {
  final bool isGameStart;

  const MyCoverScreen({required this.isGameStart});

  @override
  Widget build(BuildContext context) {
    if (isGameStart) {
      return Container();
    }
    return Container(
      alignment: const Alignment(0, -0.4),
      child: const Text(
        "Touch for starting",
        style: TextStyle(fontSize: 30, color: Colors.white),
      ),
    );
  }
}
