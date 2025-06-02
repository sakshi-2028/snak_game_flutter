import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GamePageState();
}

class _GamePageState extends State<GameScreen> {
  static const int rowSize = 20;
  static const int totalSquares = rowSize * rowSize;

  List<int> snakePos = [45, 65, 85];
  int foodPos = 105;
  String direction = 'down';

  Timer? timer;

  void startGame() {
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      updateSnake();
    });
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePos.last > totalSquares - rowSize) {
            gameOver();
            return;
          }
          snakePos.add(snakePos.last + rowSize);
          break;
        case 'up':
          if (snakePos.last < rowSize) {
            gameOver();
            return;
          }
          snakePos.add(snakePos.last - rowSize);
          break;
        case 'left':
          if (snakePos.last % rowSize == 0) {
            gameOver();
            return;
          }
          snakePos.add(snakePos.last - 1);
          break;
        case 'right':
          if ((snakePos.last + 1) % rowSize == 0) {
            gameOver();
            return;
          }
          snakePos.add(snakePos.last + 1);
          break;
      }

      if (snakePos.last == foodPos) {
        generateNewFood();
      } else {
        snakePos.removeAt(0);
      }

      if (snakePos.sublist(0, snakePos.length - 1).contains(snakePos.last)) {
        gameOver();
      }
    });
  }

  void generateNewFood() {
    Random random = Random();
    foodPos = random.nextInt(totalSquares);
    while (snakePos.contains(foodPos)) {
      foodPos = random.nextInt(totalSquares);
    }
  }

  void gameOver() {
    timer?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text("Your score: ${snakePos.length - 3}"),
          actions: [
            TextButton(
              child: const Text("Restart"),
              onPressed: () {
                Navigator.pop(context);
                restartGame();
              },
            ),
          ],
        );
      },
    );
  }

  void restartGame() {
    setState(() {
      snakePos = [45, 65, 85];
      direction = 'down';
      generateNewFood();
    });
    startGame();
  }

  void changeDirection(String newDirection) {
    if (direction == 'up' && newDirection == 'down') return;
    if (direction == 'down' && newDirection == 'up') return;
    if (direction == 'left' && newDirection == 'right') return;
    if (direction == 'right' && newDirection == 'left') return;

    setState(() {
      direction = newDirection;
    });
  }

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Snake Game"),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0) {
            changeDirection('down');
          } else if (details.delta.dy < 0) {
            changeDirection('up');
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) {
            changeDirection('right');
          } else if (details.delta.dx < 0) {
            changeDirection('left');
          }
        },
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalSquares,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowSize,
                ),
                itemBuilder: (context, index) {
                  if (snakePos.contains(index)) {
                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: index == snakePos.last ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  } else if (index == foodPos) {
                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.all(1),
                      color: Colors.grey[900],
                    );
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green[800],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Score: ${snakePos.length - 3}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
