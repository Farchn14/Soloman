import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:soloman/pixel_advanture.dart';

class Fruits extends SpriteAnimationComponent with HasGameReference<PixelAdvanture> {
  final String fruit;
  Fruits({
    this.fruit = 'Apple',
    position,
    size,
  }) : super(
          position: position,
          size: size,
          removeOnFinish: true, // PENTING: Otomatis hapus objek saat animasi selesai
        );

  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    debugMode = true; // Matikan jika sudah pas

    add(CircleHitbox(
      position: Vector2(10, 10), // Offset agar di tengah sprite 32x32
      radius: 6, 
      collisionType: CollisionType.passive,
    ));

    // Animasi Default (Buah Berputar)
    animation = _spriteAnimation(fruit, 17);

    return super.onLoad();
  }

  // Fungsi Helper untuk membuat animasi
  SpriteAnimation _spriteAnimation(String name, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$name.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void collidedWithPlayer() {
    // 1. Ganti ke animasi "Collected"
    // Karena kita pakai path assets/images/Items/Fruits/Collected.png
    animation = _spriteAnimation('Collected', 6)..loop = false; // Mainkan 1x saja

    // 2. Hilangkan hitbox agar tidak bisa ditabrak lagi saat sedang animasi hilang
    children.query<CircleHitbox>().first.removeFromParent();
    
    // Objek akan terhapus otomatis karena 'removeOnFinish: true' di constructor
  }
}