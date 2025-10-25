import 'package:flappy_bird/GameOverPopup.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'flappy_game.dart';

class GameWithStartScreen extends StatefulWidget {
  const GameWithStartScreen({super.key});

  @override
  State<GameWithStartScreen> createState() => _GameWithStartScreenState();
}

class _GameWithStartScreenState extends State<GameWithStartScreen> {
  final FlappyGame _game = FlappyGame();
  bool _showStartScreen = true;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();

    _game.onGameOver = () {
      setState(() {
        _isGameOver = true;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          if (_showStartScreen)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue.shade300.withOpacity(0.9),
                      Colors.white.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.green.shade700.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🐦 Flappy Bird Adventure!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Adventure awaits! Can you survive?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                        // shadows: [
                        //   Shadow(
                        //     color: Colors.black87,
                        //     offset: Offset(2, 2),
                        //     blurRadius: 4,
                        //   ),
                        // ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showStartScreen = false;
                          _game.isGameStarted = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                      child: const Text('Start Game'),
                    ),
                  ],
                ),
              ),
            ),
          if (_isGameOver)
            GameOverPopup(
              score: _game.score,
              onRetry: () {
                setState(() {
                  _isGameOver = false;
                  _game.resetGame();
                });
              },
            ),
        ],
      ),
    );
  }
}
