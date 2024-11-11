import 'package:flutter/material.dart';
import 'dart:math';

class SudokuGame extends StatefulWidget {
  const SudokuGame({super.key});

  @override
  _SudokuGameState createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  List<List<int?>> sudokuBoard = List.generate(9, (_) => List.filled(9, null));
  List<List<int?>> solutionBoard = List.generate(9, (_) => List.filled(9, null));
  Random random = Random();
  String difficulty = 'Medio'; // Dificultad por defecto

  @override
  void initState() {
    super.initState();
    _generateSudokuPuzzle();
  }

  void _generateSudokuPuzzle() {
    solutionBoard = _generateFullSolution();
    sudokuBoard = solutionBoard.map((row) => row.toList()).toList();
    _applyDifficulty();
  }

  List<List<int?>> _generateFullSolution() {
    return [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ];
  }

  void _applyDifficulty() {
    int emptyCells;
    if (difficulty == 'Fácil') {
      emptyCells = 30;
    } else if (difficulty == 'Medio') {
      emptyCells = 60;
    } else {
      emptyCells = 70;
    }

    int cleared = 0;
    while (cleared < emptyCells) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);
      if (sudokuBoard[row][col] != null) {
        sudokuBoard[row][col] = null;
        cleared++;
      }
    }
  }

  bool _isBoardComplete() {
    for (int i = 0; i < sudokuBoard.length; i++) {
      for (int j = 0; j < sudokuBoard[i].length; j++) {
        if (sudokuBoard[i][j] == null || sudokuBoard[i][j] != solutionBoard[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  void _checkSolution() {
    if (_isBoardComplete()) {
      _showWinDialog();
    } else {
      _showErrorDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¡Ganaste!"),
        content: const Text("Felicidades, has completado el Sudoku."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateSudokuPuzzle();
              setState(() {});
            },
            child: const Text("Jugar de nuevo"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Incorrecto"),
        content: const Text("Hay errores en tu solución. ¡Intenta nuevamente!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
  }

  void _updateDifficulty(String newDifficulty) {
    setState(() {
      difficulty = newDifficulty;
      _generateSudokuPuzzle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sudoku')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                itemCount: 81,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
                itemBuilder: (context, index) {
                  int row = index ~/ 9;
                  int col = index % 9;

                  bool thickBorderTop = row % 3 == 0;
                  bool thickBorderLeft = col % 3 == 0;
                  bool thickBorderBottom = row == 8;
                  bool thickBorderRight = col == 8;

                  return GestureDetector(
                    onTap: () async {
                      if (sudokuBoard[row][col] == null) {
                        final selectedNumber = await showDialog<int>(
                          context: context,
                          builder: (_) => const NumberPickerDialog(),
                        );
                        if (selectedNumber != null) {
                          setState(() {
                            sudokuBoard[row][col] = selectedNumber;
                          });
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: thickBorderTop ? Colors.black : Colors.grey,
                              width: thickBorderTop ? 2 : 1),
                          left: BorderSide(
                              color: thickBorderLeft ? Colors.black : Colors.grey,
                              width: thickBorderLeft ? 2 : 1),
                          bottom: BorderSide(
                              color: thickBorderBottom ? Colors.black : Colors.grey,
                              width: thickBorderBottom ? 2 : 1),
                          right: BorderSide(
                              color: thickBorderRight ? Colors.black : Colors.grey,
                              width: thickBorderRight ? 2 : 1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          sudokuBoard[row][col]?.toString() ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkSolution,
              child: const Text("Comprobar"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Configuración"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text("Fácil"),
                          leading: Radio<String>(
                            value: "Fácil",
                            groupValue: difficulty,
                            onChanged: (value) => _updateDifficulty(value!),
                          ),
                        ),
                        ListTile(
                          title: const Text("Medio"),
                          leading: Radio<String>(
                            value: "Medio",
                            groupValue: difficulty,
                            onChanged: (value) => _updateDifficulty(value!),
                          ),
                        ),
                        ListTile(
                          title: const Text("Difícil"),
                          leading: Radio<String>(
                            value: "Difícil",
                            groupValue: difficulty,
                            onChanged: (value) => _updateDifficulty(value!),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text("Configuración"),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberPickerDialog extends StatelessWidget {
  const NumberPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Selecciona un número"),
      content: Wrap(
        children: List.generate(9, (index) {
          return ElevatedButton(
            onPressed: () => Navigator.pop(context, index + 1),
            child: Text((index + 1).toString()),
          );
        }),
      ),
    );
  }
}




