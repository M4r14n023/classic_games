import 'package:flutter/material.dart';

class Hangman extends StatefulWidget {
  const Hangman({super.key});

  @override
  _HangmanState createState() => _HangmanState();
}

class _HangmanState extends State<Hangman> {
  String? word; // Palabra elegida por el jugador 1
  List<String> guessedLetters = [];
  int triesLeft = 0;
  final TextEditingController wordController = TextEditingController();

  bool get gameWon => word != null && word!.split('').every((letter) => guessedLetters.contains(letter));

  String _displayWord() {
    if (word == null) return '';
    return word!.split('').map((letter) {
      return guessedLetters.contains(letter) ? letter : '_';
    }).join(' ');
  }

  void _guessLetter(String letter) {
    if (!guessedLetters.contains(letter) && triesLeft > 0) {
      setState(() {
        guessedLetters.add(letter);
        if (!word!.contains(letter)) {
          triesLeft--;
        }
      });
    }
  }

  void _startGame(String chosenWord) {
    setState(() {
      word = chosenWord.toUpperCase();
      guessedLetters.clear();
      triesLeft = word!.length * 2; // Intentos = doble de letras de la palabra
      wordController.clear(); // Limpiar el campo de texto al iniciar el juego
    });
  }

  void _checkIfWon() {
    if (gameWon) {
      _showGameResultDialog(victory: true);
    } else {
      _showGameResultDialog(victory: false);
    }
  }

  void _showGameResultDialog({required bool victory}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(victory ? '¡Ganaste!' : '¡Aún no has ganado!'),
        content: Text(victory
            ? 'Felicidades, has adivinado la palabra correctamente.'
            : 'Aún te faltan letras por adivinar.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (victory) {
                setState(() {
                  word = null;
                });
              }
            },
            child: Text(victory ? 'Volver a jugar' : 'Seguir jugando'),
          ),
        ],
      ),
    );
  }

  void _navigateToCompetition() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HangmanCompetition()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ahorcado')),
      body: word == null ? _buildWordInput() : _buildGame(),
    );
  }

  Widget _buildWordInput() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Jugador 1, ingresa la palabra:', style: TextStyle(fontSize: 24)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: wordController,
              decoration: const InputDecoration(labelText: 'Palabra', border: OutlineInputBorder()),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String chosenWord = wordController.text.toUpperCase();
              if (chosenWord.isNotEmpty) {
                _startGame(chosenWord);
              }
            },
            child: const Text('Iniciar Juego'),
          ),
                  const SizedBox(height: 20), // Espaciado entre botones
        ElevatedButton(
          onPressed: _navigateToCompetition,
          child: const Text('Modo Competencia'),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Palabra: ${_displayWord()}', style: const TextStyle(fontSize: 24)),
        Text('Intentos restantes: $triesLeft', style: const TextStyle(fontSize: 20)),
        Wrap(
          children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                onPressed: triesLeft > 0 ? () => _guessLetter(letter) : null,
                child: Text(letter),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _checkIfWon,
          child: const Text('Verificar palabra completa'),
        ),
      ],
    );
  }
}

// Aquí puedes agregar el código para el modo de competencia

  // Lógica del modo de competencia aquí
class HangmanCompetition extends StatefulWidget {
  const HangmanCompetition({super.key});

  @override
  _HangmanCompetitionState createState() => _HangmanCompetitionState();
}

class _HangmanCompetitionState extends State<HangmanCompetition> {
  String? word;
  List<String> guessedLetters = [];
  int triesLeft = 12;
  int player1Score = 0;
  int player2Score = 0;
  int gamesToWin = 3; // Default: "best of 3"
  bool player1Turn = true;
  String player1Name = "Jugador 1";
  String player2Name = "Jugador 2";

  bool get gameOver => triesLeft <= 0 || _displayWord() == word;

  String _displayWord() {
    if (word == null) return '';
    return word!.split('').map((letter) {
      return guessedLetters.contains(letter) ? letter : '_';
    }).join(' ');
  }

  void _guessLetter(String letter) {
    if (!guessedLetters.contains(letter) && !gameOver) {
      setState(() {
        guessedLetters.add(letter);
        if (!word!.contains(letter)) {
          triesLeft--;
        }
      });
    }
  }

  void _startNewRound() {
    guessedLetters.clear();
    triesLeft = word!.length * 2; // Set tries based on word length
    player1Turn = !player1Turn; // Alternate players
  }

  void _checkForWinner() {
    if (_displayWord() == word) {
      setState(() {
        player1Turn ? player1Score++ : player2Score++;
      });
      if (player1Score == gamesToWin || player2Score == gamesToWin) {
        _showGameWinner();
      } else {
        _startNewRound();
      }
    } else if (triesLeft == 0) {
      _startNewRound();
    }
  }

  void _showGameWinner() {
    String winner = player1Score > player2Score ? player1Name : player2Name;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("¡$winner ganó la serie!"),
        content: const Text("¿Quieres jugar de nuevo?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text("Reiniciar"),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      player1Score = 0;
      player2Score = 0;
      player1Turn = true;
    });
    _startNewRound();
  }

  void _setWord(String newWord) {
    setState(() {
      word = newWord.toUpperCase();
      triesLeft = newWord.length * 2;
      guessedLetters.clear();
    });
  }

  void _openSetupDialog() {
    final TextEditingController player1Controller = TextEditingController();
    final TextEditingController player2Controller = TextEditingController();
    int selectedGamesToWin = 3;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Configuración de la competencia"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: player1Controller,
              decoration: const InputDecoration(labelText: "Nombre Jugador 1"),
            ),
            TextField(
              controller: player2Controller,
              decoration: const InputDecoration(labelText: "Nombre Jugador 2"),
            ),
            DropdownButton<int>(
              value: selectedGamesToWin,
              items: [3, 5, 7].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("Mejor de $value"),
                );
              }).toList(),
              onChanged: (value) {
                selectedGamesToWin = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                player1Name = player1Controller.text.isEmpty
                    ? "Jugador 1"
                    : player1Controller.text;
                player2Name = player2Controller.text.isEmpty
                    ? "Jugador 2"
                    : player2Controller.text;
                gamesToWin = selectedGamesToWin;
              });
              Navigator.pop(context);
            },
            child: const Text("Empezar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ahorcado - Competencia')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (word == null) _buildWordInput(),
          if (word != null) _buildGameBoard(),
                  const SizedBox(height: 20), // Espaciado entre botones
        ElevatedButton(
          onPressed: _openSetupDialog,
          child: const Text("Configuración"),
          ),
        ],
      ),
    );
  }

  Widget _buildWordInput() {
    final TextEditingController wordController = TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${player1Turn ? player1Name : player2Name}, elige una palabra:"),
        TextField(
          controller: wordController,
          decoration: const InputDecoration(labelText: "Palabra"),
          obscureText: true,
        ),
        ElevatedButton(
          onPressed: () {
            String newWord = wordController.text;
            if (newWord.isNotEmpty) _setWord(newWord);
          },
          child: const Text("Iniciar Juego"),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return Column(
      children: [
        Text('Turno: ${player1Turn ? player1Name : player2Name}'),
        Text('Palabra: ${_displayWord()}', style: const TextStyle(fontSize: 24)),
        Text('Intentos restantes: $triesLeft', style: const TextStyle(fontSize: 20)),
        Wrap(
          children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                onPressed: gameOver ? null : () {
                  _guessLetter(letter);
                  _checkForWinner();
                },
                child: Text(letter),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}





