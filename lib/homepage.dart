import 'dart:async';

import 'package:flappy_bird/bird.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double birdY = 0; // this arrang is from 1 to -1
  double initialPos = 0;
  double height = 0;
  double time = 0;
  double gravity = -4.9; // how strong the gravity is
  double velocity = 2.5; // how strong the jump is

  bool isGameStart = false;

  void startGame() {
    isGameStart = true;
    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      // now we have formular to convert state of bird when it fly
      // y = -(gt^2)/2 + vt
      // ex: y = -4.9t^2 + 30t

      height = gravity * time * time + velocity * time;

      setState(() {
        birdY = initialPos - height;
      });

      if (birdIsDead()) {
        timer.cancel();
        isGameStart = false;
        _showDialog();
      }
      print(birdY);
      time += 0.001;
    });
  }

  void _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.brown,
              title: const Center(
                child: Text(
                  "G A M E O V E R",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: resetGame,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                        padding: const EdgeInsets.all(7),
                        color: Colors.white,
                        child: const Text("PLAY AGAIN",
                            style: TextStyle(color: Colors.brown))),
                  ),
                )
              ]);
        });
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      birdY = 0;
      isGameStart = false;
      time = 0;
      initialPos = birdY;
    });
  }

  void jump() {
    time = 0;
    setState(() {
      time = 0;
      initialPos = birdY;
    });
  }

  bool birdIsDead() {
    if (birdY < -1 || birdY > 1) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGameStart ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
                flex: 5,
                child: Container(
                    color: Colors.blue,
                    child: Center(
                      child: Stack(
                        children: [
                          !isGameStart
                              ? Container(
                                  alignment: const Alignment(0, -0.4),
                                  child: const Text(
                                    "Touch for starting",
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.white),
                                  ),
                                )
                              : Container(),
                          MyBird(birdY: birdY),
                        ],
                      ),
                    ))),
            Expanded(flex: 1, child: Container(color: Colors.brown)),
          ],
        ),
      ),
    );
  }
}

class Barrier {
  double barrierY = 0;
  double barrierX = 0;
  Barrier(this.barrierX, this.barrierY);
}
