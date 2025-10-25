import 'package:flame/components.dart';

class Bird extends SpriteComponent {
  Vector2 velocity = Vector2.zero();

  Bird() : super(size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('flappy_bird.png');
    position = Vector2(100, 200);
    anchor = Anchor.center;
  }
}
