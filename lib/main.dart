import 'package:flutter/material.dart';
import 'tic_tac_toe/tic_tac_toe.dart';
//import 'tic_tac_toe/tic_tac_toe_competition.dart'; // Nueva importación para el modo competencia
import 'hangman/hangman.dart';
//import 'hangman/hangman_competition.dart'; // Nueva importación para el modo competencia
import 'snake/snake.dart';
import 'sudoku/sudoku.dart';

void main() => runApp(const ClassicGamesApp());

class ClassicGamesApp extends StatelessWidget {
  const ClassicGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juegos Clásicos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      routes: {
        '/tic-tac-toe': (context) => const TicTacToe(),
        '/tic-tac-toe-competition': (context) => const TicTacToeCompetition(), // Nueva ruta
        '/hangman': (context) => const Hangman(),
        '/hangman-competition': (context) => const HangmanCompetition(), // Nueva ruta
        '/sudoku': (context) => const SudokuGame(),
        '/snake': (context) => const SnakeGame(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Juegos Clásicos')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GameButton(title: 'Ta-Te-Ti', routeName: '/tic-tac-toe'),
            //GameButton(title: 'Ta-Te-Ti - Competencia', routeName: '/tic-tac-toe-competition'), // Nueva opción
            GameButton(title: 'Ahorcado', routeName: '/hangman'),
            //GameButton(title: 'Ahorcado - Competencia', routeName: '/hangman-competition'), // Nueva opción
            GameButton(title: 'Sudoku', routeName: '/sudoku'),
            GameButton(title: 'Snake', routeName: '/snake'),
          ],
        ),
      ),
    );
  }
}

class GameButton extends StatelessWidget {
  final String title;
  final String routeName;

  const GameButton({super.key, required this.title, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, routeName),
        style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
        child: Text(title, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}


