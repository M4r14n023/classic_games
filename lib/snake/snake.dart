import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int rows = 20;
  final int columns = 20;
  final int cellSize = 20;
  List<Point<int>> snake = [const Point(0, 0)];
  Point<int> food = const Point(5, 5);
  String direction = 'right';
  Timer? gameTimer;
  int score = 0;
  int highScore = 0;
  String backgroundImagePath = 'build/flutter_assets/grass.webp';

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _startGame();
  }

  Future<void> _loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = (prefs.getInt('highScore') ?? 0);
    });
  }

  void _startGame() {
    score = 0;
    snake = [const Point(0, 0)];
    direction = 'right';
    gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _moveSnake();
      });
    });
  }

  void _moveSnake() {
    Point<int> newHead;
    switch (direction) {
      case 'up':
        newHead = Point(snake.first.x, snake.first.y - 1);
        break;
      case 'down':
        newHead = Point(snake.first.x, snake.first.y + 1);
        break;
      case 'left':
        newHead = Point(snake.first.x - 1, snake.first.y);
        break;
      case 'right':
        newHead = Point(snake.first.x + 1, snake.first.y);
        break;
      default:
        newHead = snake.first;
    }

    snake.insert(0, newHead);
    if (snake.first == food) {
      _generateNewFood();
      score++;
      if (score > highScore) {
        highScore = score;
        backgroundImagePath = 'build/flutter_assets/grass2.avif';
        _saveHighScore();
      }
    } else {
      snake.removeLast();
    }

    if (_isGameOver(newHead)) {
      gameTimer?.cancel();
      _showGameOverDialog();
    }
  }

  bool _isGameOver(Point<int> head) {
    return head.x < 0 || head.x >= columns || head.y < 0 || head.y >= rows || snake.skip(1).contains(head);
  }

  void _generateNewFood() {
    final random = Random();
    food = Point(random.nextInt(columns), random.nextInt(rows));
  }

  Future<void> _saveHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('highScore', highScore);
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Juego Terminado'),
        content: Text('Puntuación: $score\nRécord: $highScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
              backgroundImagePath = 'build/flutter_assets/grass.webp';
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  void _changeDirection(String newDirection) {
    if (newDirection == 'left' && direction != 'right' ||
        newDirection == 'right' && direction != 'left' ||
        newDirection == 'up' && direction != 'down' ||
        newDirection == 'down' && direction != 'up') {
      setState(() {
        direction = newDirection;
      });
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyLabel) {
        case 'Arrow Up':
          _changeDirection('up');
          break;
        case 'Arrow Down':
          _changeDirection('down');
          break;
        case 'Arrow Left':
          _changeDirection('left');
          break;
        case 'Arrow Right':
          _changeDirection('right');
          break;
      }
    }
  }

  double _getRotationAngle(String direction) {
    switch (direction) {
      case 'up':
        return 0;
      case 'down':
        return pi;
      case 'left':
        return -pi / 2;
      case 'right':
        return pi / 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serpiente')),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyPress,
        child: Column(
          children: [
            // Marcador centrado arriba del juego
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Puntuación: $score    Récord: $highScore',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 150, 39, 39),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0) _changeDirection('down');
                    if (details.delta.dy < 0) _changeDirection('up');
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0) _changeDirection('right');
                    if (details.delta.dx < 0) _changeDirection('left');
                  },
                  child: Container(
                    width: columns * cellSize.toDouble(),
                    height: rows * cellSize.toDouble(),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(backgroundImagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: food.y * cellSize.toDouble(),
                          left: food.x * cellSize.toDouble(),
                          child: Image.asset(
                            'build/flutter_assets/fruit.png',
                            width: cellSize.toDouble(),
                            height: cellSize.toDouble(),
                          ),
                        ),
                        ...snake.map((point) {
                          return Positioned(
                            top: point.y * cellSize.toDouble(),
                            left: point.x * cellSize.toDouble(),
                            child: point == snake.first
                                ? Transform.rotate(
                                    angle: _getRotationAngle(direction),
                                    child: Image.asset(
                                      'build/flutter_assets/snake_head.png',
                                      width: cellSize.toDouble(),
                                      height: cellSize.toDouble(),
                                    ),
                                  )
                                  : Transform.rotate(
                                    angle: _getRotationAngle(direction), // Aplica la rotación también al cuerpo
                                    child: Image.asset(
                                    'build/flutter_assets/oval.png',
                                    width: cellSize.toDouble(),
                                    height: cellSize.toDouble(),
                                  ),
                          ));
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}









