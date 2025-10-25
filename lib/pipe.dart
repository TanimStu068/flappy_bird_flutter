import 'dart:math';
import 'package:flame/components.dart';

class Pipe extends PositionComponent {
  late final SpriteComponent topPipe;
  late final SpriteComponent bottomPipe;
  bool passed = false;
  final double speed = 200;

  Pipe(
    double screenWidth,
    double screenHeight,
    Sprite pipeSprite,
    double groundHeight,
  ) {
    double pipeWidth = 60;
    double gap = 150;

    // Random center of the gap
    double maxCenterY = screenHeight - groundHeight - gap / 2;
    double centerY = Random().nextDouble() * (maxCenterY - gap / 2) + gap / 2;

    // Top pipe: stretch from top to top of gap
    topPipe = SpriteComponent()
      ..sprite = pipeSprite
      ..size = Vector2(pipeWidth, centerY - gap / 2)
      ..position = Vector2(screenWidth, 0)
      ..anchor = Anchor.bottomLeft
      ..flipVertically();

    // Bottom pipe: stretch from bottom of gap to top of ground
    double bottomPipeHeight = screenHeight - groundHeight - (centerY + gap / 2);
    bottomPipe = SpriteComponent()
      ..sprite = pipeSprite
      ..size = Vector2(pipeWidth, bottomPipeHeight)
      ..position = Vector2(screenWidth, centerY + gap / 2)
      ..anchor = Anchor.topLeft;

    add(topPipe);
    add(bottomPipe);
  }

  @override
  void update(double dt) {
    super.update(dt);
    topPipe.x -= speed * dt;
    bottomPipe.x -= speed * dt;
  }

  bool isOffScreen() {
    return topPipe.x + topPipe.width < 0;
  }
}
