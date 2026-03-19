import 'package:flame/collisions.dart';

bool checkCollisions(player, block) {
  final hitbox = player.children.query<RectangleHitbox>().first;
  
  final playerX = player.position.x + (player.scale.x > 0 ? hitbox.x : -hitbox.x - hitbox.width);
  final playerY = player.position.y + hitbox.y; // Gunakan playerY yang murni
  
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  return (
    playerY < blockY + blockHeight &&
    playerY + playerHeight > blockY &&
    playerX < blockX + blockWidth &&
    playerX + playerWidth > blockX
  );
}