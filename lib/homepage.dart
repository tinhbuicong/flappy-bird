import 'dart:async';

import 'package:flappy_bird/barrier.dart';
import 'package:flappy_bird/bird.dart';
import 'package:flappy_bird/coverScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double birdHeight = 0.1;
  double birdWidth = 0.1;

  bool isGameStart = false;
  static List<double> barrierX = [2, 2 + 1.5];
  static List<bool> flag = [false, false];
  static double barrierWidth = 0.5;
  int score = 0;
  int bestScore = 0;
  List<List<double>> barrierHeight = [
    [0.6, 0.4],
    [0.4, 0.6],
    [0.5, 0.8],
    [0.7, 0.9],
    [0.1, 0.3],
    [0.8, 1]
  ];

  @override
  void initState() {
    super.initState();
    setDefaultData();
  }

  setDefaultData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? best = prefs.getInt('best');
    if (best == null) {
      await prefs.setInt('best', 0);
      setState(() {
        bestScore = 0;
      });
      return;
    }
    setState(() {
      bestScore = best;
    });
  }

  void startGame() {
    isGameStart = true;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      // now we have formular to convert state of bird when it fly
      // y = -(gt^2)/2 + vt
      // ex: y = -4.9t^2 + 30t

      height = gravity * time * time + velocity * time;
      moveMap();
      setState(() {
        birdY = initialPos - height;
      });
      increaseScore();
      if (birdIsDead()) {
        _updateTheBest();
        timer.cancel();
        isGameStart = false;
        _showDialog();
      }
      time += 0.01;
    });
  }

  void _updateTheBest() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? best = prefs.getInt('counter');
    if (best == null || best < score) {
      await prefs.setInt('best', score);
      setState(() {
        bestScore = score;
      });
      return;
    }
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
      barrierX = [2, 2 + 1.5];
      flag = [false, false];
    });
  }

  void jump() {
    time = 0;
    setState(() {
      time = 0;
      initialPos = birdY;
    });
  }

  void increaseScore() {
    for (int i = 0; i < barrierX.length; i++) {
      if (!flag[i] && barrierX[i] <= -0.5) {
        setState(() {
          flag[i] = true;
          ++score;
        });
      }
    }
  }

  void moveMap() {
    for (int i = 0; i < barrierX.length; i++) {
      setState(() {
        barrierX[i] -= 0.005;
      });
      if (barrierX[i] < -1.5) {
        flag[i] = false;
        barrierX[i] += 3;
      }
    }
  }

  bool birdIsDead() {
    if (birdY < -1 || birdY > 1) {
      return true;
    }

    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= birdWidth &&
          barrierX[i] + barrierWidth >= -birdWidth &&
          (birdY <= -1 + barrierHeight[i][0] ||
              birdY + birdHeight >= 1 - barrierHeight[i][1])) {
        return true;
      }
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
                          MyCoverScreen(isGameStart: isGameStart),
                          // bird
                          MyBird(
                              birdY: birdY,
                              birdWidth: birdWidth,
                              birdHeight: birdHeight),

                          //top barrier 0
                          MyBarrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[0][0],
                            isThisBottomBarrier: false,
                          ),
                          //bottom barrier 0
                          MyBarrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[0][1],
                            isThisBottomBarrier: true,
                          ),

                          //top barrier 1
                          MyBarrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[1][0],
                            isThisBottomBarrier: false,
                          ),
                          //bottom barrier 1
                          MyBarrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[1][1],
                            isThisBottomBarrier: true,
                          )
                        ],
                      ),
                    ))),
            Expanded(
                flex: 1,
                child: Container(
                    color: Colors.brown,
                    child: Stack(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                          alignment: const Alignment(-0.5, 1),
                          child: Column(children: [
                            Text(
                              score.toString(),
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            const Text(
                              "S C O R E",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            )
                          ]),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                          alignment: const Alignment(0.5, 0),
                          child: Column(children: [
                            Text(
                              bestScore.toString(),
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            const Text(
                              "B E S T",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            )
                          ]),
                        ),
                      ],
                    ))),
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
