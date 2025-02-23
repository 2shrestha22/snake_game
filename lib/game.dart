import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/dpad.dart';
import 'package:snake_game/game_audio.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final board = Board(height: 40, width: 40);
  late Snake snake;

  final focusNode = FocusNode();

  int points = 0;

  @override
  void initState() {
    snake = Snake(
      board: board,
      onUpdate: (foodConsumed) {
        if (foodConsumed) {
          points++;
          snake.increaseSpeed();
        }
        setState(() {});
      },
      onOver: () async {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text('Game Over!')),
        );
        setState(() {
          points = 0;
        });
        snake.start();
      },
    )..start();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    FocusScope.of(context).requestFocus(focusNode);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Score: $points',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ),
              Expanded(
                child: KeyboardListener(
                  focusNode: focusNode,
                  onKeyEvent: (event) {
                    setState(() {
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        snake.direction = Direction.up;
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowDown) {
                        snake.direction = Direction.down;
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowLeft) {
                        snake.direction = Direction.left;
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowRight) {
                        snake.direction = Direction.right;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: board.width / board.height,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: GamePainter(
                                  board: board,
                                  snake: snake,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Dpad(onTap: (direction) => snake.direction = direction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum Direction {
  right,
  left,
  up,
  down;

  bool isInverse(Direction direction) {
    return direction == Direction.right && this == Direction.left ||
        direction == Direction.up && this == Direction.down ||
        direction == Direction.left && this == Direction.right ||
        direction == Direction.down && this == Direction.up;
  }
}

class Snake {
  Snake({required this.onUpdate, required this.board, required this.onOver});

  final Board board;

  final Function(bool foodConsumed) onUpdate;
  final VoidCallback onOver;

  late Timer timer;

  // [tail, .... ,head]
  late List<int> body;
  set head(int value) => body[body.length - 1] = value;
  int get head => body.last;

  /// set next direction to move
  set direction(Direction d) {
    if (d.isInverse(_movingDirection)) return;
    _direction = d;
  }

  late Direction _movingDirection;
  late Direction _direction;

  late int speed;

  void start() {
    speed = 300;
    final newHead = Random().nextInt(board.height * board.width - 2);
    body = [newHead, newHead + 1];

    _direction = Direction.values[Random().nextInt(4)];
    _movingDirection = _direction;

    timer = Timer.periodic(Duration(milliseconds: speed), (_) {
      _movingDirection = _direction;
      _move();
    });
  }

  /// Increase speed by 1%
  void increaseSpeed() {
    timer.cancel();
    speed = speed - speed * 1 ~/ 100;
    timer = Timer.periodic(Duration(milliseconds: speed), (_) {
      _movingDirection = _direction;
      _move();
    });
  }

  void _move() {
    if (body.sublist(0, body.length - 1).contains(head)) {
      // over the game if head touches the snake body
      onOver();
      timer.cancel();
      return;
    }

    switch (_direction) {
      case Direction.right:
        body.add(
          (head + 1) % board.width + board.width * (head ~/ board.width),
        );
        break;
      case Direction.left:
        body.add(
          (head - 1) % board.width + board.width * (head ~/ board.width),
        );
        break;
      case Direction.up:
        body.add((head - board.width) % (board.width * board.height));
        break;
      case Direction.down:
        body.add((head + board.width) % (board.width * board.height));
        break;
    }

    final foodConsumed = board.food == head;

    onUpdate(foodConsumed);

    // remove the tail if food is not consumed otherwise don't
    if (!foodConsumed) {
      body.removeAt(0);
    } else {
      GameAudio.playBite();
      board.spwanFood();
    }
  }
}

class Board {
  final int height;
  final int width;

  Board({required this.height, required this.width}) {
    spwanFood();
  }

  void spwanFood() {
    food = Random().nextInt(height * width);
  }

  late int food;
}

class GamePainter extends CustomPainter {
  final Board board;
  final Snake snake;

  GamePainter({required this.board, required this.snake});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = min(size.width / board.width, size.height / board.height);

    final paint = Paint();

    // Draw background
    paint.color = Colors.black;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, board.width * cellSize, board.height * cellSize),
      paint,
    );

    // Draw food
    paint.color = Colors.white;
    final foodX = (board.food % board.width) * cellSize;
    final foodY = (board.food ~/ board.width) * cellSize;
    canvas.drawRect(Rect.fromLTWH(foodX, foodY, cellSize, cellSize), paint);

    // Draw snake body
    for (final index in snake.body) {
      final x = (index % board.width) * cellSize;
      final y = (index ~/ board.width) * cellSize;
      paint.color = index == snake.head ? Colors.red : Colors.green;
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), paint);
    }

    // Draw border
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1; // Border thickness
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
