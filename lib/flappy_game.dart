import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'bird.dart';
import 'pipe.dart';

class FlappyGame extends FlameGame with TapDetector {
  SpriteComponent? background;
  SpriteComponent? ground;
  Bird? bird;
  final List<Pipe> pipes = [];
  int score = 0;
  bool isGameOver = false;
  bool isGameStarted = false;
  VoidCallback? onGameOver;

  double gravity = 800;
  double pipeSpawnTimer = 0.0;
  final double pipeSpawnInterval = 2.0;

  late final Sprite pipeSprite;
  late final Sprite groundSprite;
  double groundHeight = 50;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    //preload all audio
    await FlameAudio.audioCache.loadAll([
      'music/score_effect.mp3',
      'music/game_over.mp3',
    ]);

    // Load images
    await images.loadAll([
      'bg.png',
      'pipe.png',
      'flappy_bird.png',
      'ground.png',
    ]);
    pipeSprite = Sprite(images.fromCache('pipe.png'));
    groundSprite = Sprite(images.fromCache('ground.png'));

    // Background
    background = SpriteComponent()
      ..sprite = Sprite(images.fromCache('bg.png'))
      ..size = size
      ..priority = -1;
    await add(background!);

    // Ground
    ground = SpriteComponent()
      ..sprite = groundSprite
      ..size = Vector2(size.x, groundHeight)
      ..position = Vector2(0, size.y - groundHeight)
      ..anchor = Anchor.topLeft;
    await add(ground!);

    // Bird
    bird = Bird()
      ..sprite = Sprite(images.fromCache('flappy_bird.png'))
      ..size = Vector2(50, 50)
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 4, size.y / 2);
    await add(bird!);
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    background?.size = newSize;
    ground?.size = Vector2(newSize.x, groundHeight);
    ground?.position = Vector2(0, newSize.y - groundHeight);
    bird?.position = Vector2(newSize.x / 4, newSize.y / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameStarted || isGameOver) return;
    if (bird == null || size.x == 0 || size.y == 0) return;

    // Gravity
    bird!.velocity.y += gravity * dt;
    bird!.position.y += bird!.velocity.y * dt;

    // Spawn pipes
    pipeSpawnTimer += dt;
    if (pipeSpawnTimer > pipeSpawnInterval) {
      final pipe = Pipe(size.x, size.y, pipeSprite, groundHeight);
      pipes.add(pipe);
      add(pipe);
      pipeSpawnTimer = 0.0;
    }

    // Collision & scoring
    for (var pipe in pipes) {
      if (bird!.toRect().overlaps(pipe.topPipe.toRect()) ||
          bird!.toRect().overlaps(pipe.bottomPipe.toRect())) {
        gameOver();
        return;
      }

      if (!pipe.passed &&
          pipe.topPipe.position.x + pipe.topPipe.width < bird!.position.x) {
        score++;
        pipe.passed = true;

        //play coin sound
        FlameAudio.play('music/score_effect.mp3');
      }
    }

    // Remove off-screen pipes
    pipes.removeWhere((Pipe pipe) {
      // explicitly type pipe as non-nullable
      if (pipe.isOffScreen()) {
        pipe.removeFromParent();
        return true;
      }
      return false;
    });

    // Ground / ceiling collision
    if (bird!.position.y > size.y - groundHeight - bird!.height / 2 ||
        bird!.position.y < 0) {
      gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Score
    final scorePainter = TextPainter(
      text: TextSpan(
        text: 'Score: $score',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    scorePainter.paint(canvas, Offset(size.x / 2 - scorePainter.width / 2, 20));
  }

  @override
  void onTap() {
    if (isGameOver) {
      resetGame();
    } else {
      bird?.velocity.y = -350; // flap
    }
  }

  void gameOver() {
    isGameOver = true;
    bird?.velocity = Vector2.zero();

    //stop background music
    FlameAudio.bgm.stop();

    //game over sound effect
    FlameAudio.play('music/game_over.mp3');

    onGameOver?.call();
  }

  void resetGame() {
    isGameOver = false;
    bird?.position = Vector2(size.x / 4, size.y / 2);
    bird?.velocity = Vector2.zero();
    score = 0;

    for (var pipe in pipes) {
      pipe.removeFromParent();
    }
    pipes.clear();
    pipeSpawnTimer = 0.0;
  }
}
