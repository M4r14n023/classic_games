import 'package:flutter/material.dart';

class TicTacToe extends StatefulWidget {
  const TicTacToe({super.key});

  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<String> board = List.filled(9, '');
  bool isX = true;
  String result = '';

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      isX = true;
      result = '';
    });
  }

  void _markCell(int index) {
    if (board[index] == '' && result == '') {
      setState(() {
        board[index] = isX ? 'X' : 'O';
        isX = !isX;
        result = _checkWinner();
      });
    }
  }

  String _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Filas
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columnas
      [0, 4, 8], [2, 4, 6] // Diagonales
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]] &&
          board[pattern[0]] != '') {
        return '${board[pattern[0]]} gana!';
      }
    }

    return board.contains('') ? '' : 'Empate!';
  }

  void _navigateToCompetition() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TicTacToeCompetition()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ta-Te-Ti')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _navigateToCompetition,
              child: const Text('Modo Competencia'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _markCell(index),
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    color: Colors.blue[100],
                    child: Center(
                      child: Text(
                        board[index],
                        style: const TextStyle(fontSize: 48, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (result.isNotEmpty)
              Column(
                children: [
                  Text(
                    result,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _resetGame,
                    child: const Text('Reiniciar Juego'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Clase para el modo de competencia
class TicTacToeCompetition extends StatefulWidget {
  const TicTacToeCompetition({super.key});

  @override
  _TicTacToeCompetitionState createState() => _TicTacToeCompetitionState();
}

class _TicTacToeCompetitionState extends State<TicTacToeCompetition> {
  List<String> board = List.filled(9, '');
  bool isX = true;
  String result = '';
  int player1Score = 0;
  int player2Score = 0;
  int gamesToWin = 3; // Default: "best of 3"
  String player1Name = "Jugador 1";
  String player2Name = "Jugador 2";

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      isX = true;
      result = '';
    });
  }

  void _markCell(int index) {
    if (board[index] == '' && result == '') {
      setState(() {
        board[index] = isX ? 'X' : 'O';
        isX = !isX;
        result = _checkWinner();
        if (result.isNotEmpty) {
          _updateScore();
        }
      });
    }
  }

  String _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Filas
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columnas
      [0, 4, 8], [2, 4, 6] // Diagonales
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]] &&
          board[pattern[0]] != '') {
        return '${board[pattern[0]]} gana!';
      }
    }

    return board.contains('') ? '' : 'Empate!';
  }

  void _updateScore() {
    if (result.contains('X')) {
      player1Score++;
    } else if (result.contains('O')) {
      player2Score++;
    }
    if (player1Score == gamesToWin || player2Score == gamesToWin) {
      _showGameWinner();
    } else {
      _resetGame();
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
              _resetAll();
            },
            child: const Text("Reiniciar"),
          ),
        ],
      ),
    );
  }

  void _resetAll() {
    setState(() {
      player1Score = 0;
      player2Score = 0;
    });
    _resetGame();
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
      appBar: AppBar(title: const Text('Ta-Te-Ti - Competencia')),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (board.isEmpty) _buildWordInput(),
          if (board.isNotEmpty) _buildGameBoard(),
          ElevatedButton(
            onPressed: _openSetupDialog,
            child: const Text("Configuración"),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildWordInput() {
    final TextEditingController wordController = TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Jugador, elige una palabra:"),
        TextField(
          controller: wordController,
          decoration: const InputDecoration(labelText: "Palabra"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              // Implement logic to start the game
            });
          },
          child: const Text("Comenzar Juego"),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return Column(
      children: [
        Text(
          "$player1Name: $player1Score - $player2Name: $player2Score",
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          height: 300,
          child: GridView.builder(
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _markCell(index),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                color: Colors.blue[100],
                child: Center(
                  child: Text(
                    board[index],
                    style: const TextStyle(fontSize: 48, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (result.isNotEmpty)
          Column(
            children: [
              Text(
                result,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _resetGame,
                child: const Text('Reiniciar Juego'),
              ),
            ],
          ),
      ],
    );
  }
}




