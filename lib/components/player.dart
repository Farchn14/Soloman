import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:soloman/components/collisions_block.dart';
import 'package:soloman/components/utils.dart';
import 'package:soloman/pixel_advanture.dart';
import 'package:soloman/components/fruit.dart';

enum PlayerState {idle, running, jumping, falling}



class Player extends SpriteAnimationGroupComponent with HasGameReference <PixelAdvanture>, KeyboardHandler, CollisionCallbacks{
  String character;
  Player({
    position, this.character = 'Virtual Guy',
    }) :super(
      position: position,
      anchor:  Anchor.center,
    );


  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;

final double _gravity = 12.7;
final double _jumpForce = 252;
final double _doubleJumpForce = 205;
final double _terminalVelocity = 450;
final double _fallAcceleration = 1.5;
double horizontalMovement = 0;
double moveSpeed = 122;
Vector2 velocity = Vector2.zero();
bool isOnGround = false;
bool hasJump = false;
bool hasJumped = false;
bool _jumpPressed = false; 
bool canDoubleJump = false;
List<CollisionsBlock> collisionsBlocks = [];


 @override
  FutureOr<void> onLoad() async {
    add(RectangleHitbox(
    position: Vector2(-8, -14), 
    size: Vector2(16, 28),
    collisionType: CollisionType.active,
  ));
    // Pastikan path di sini SAMA PERSIS dengan nama file di folder assets
    await game.images.load('Main Characters/Virtual Guy/Idle (32x32).png');
    await game.images.load('Main Characters/Virtual Guy/Run (32x32).png');
    debugMode = true;
    _loadAllAnimation();
    return super.onLoad();
  }

@override
void update(double dt) {
  // Jika dt terlalu besar (lag), paksa jadi 0.017 (sekitar 60fps)
  double fixedDeltaTime = dt > 0.02 ? 0.017 : dt; 

  _updatePlayerState();
  _updatePlayerMovement(fixedDeltaTime);
  _checkHorizontalCollisions();
  _applayGravity(fixedDeltaTime);
  _checkVerticalCollisions();
  
  super.update(dt);
}

@override
bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  horizontalMovement = 0;
  final isPresKiri = keysPressed.contains(LogicalKeyboardKey.keyA) || 
                     keysPressed.contains(LogicalKeyboardKey.arrowLeft);
  final isPresKanan = keysPressed.contains(LogicalKeyboardKey.keyD) || 
                      keysPressed.contains(LogicalKeyboardKey.arrowRight);

  horizontalMovement += isPresKiri ? -1 : 0;
  horizontalMovement += isPresKanan ? 1 : 0;

  // Cek apakah Spasi SEDANG DITEKAN (untuk Variable Jump)
  hasJump = keysPressed.contains(LogicalKeyboardKey.space);

  return super.onKeyEvent(event, keysPressed);
}
  void _loadAllAnimation() {
    // Gunakan path yang identik dengan yang di-load di atas

    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
  
void _updatePlayerState() {
  PlayerState playerState = PlayerState.idle;

  // Mengatur arah hadap (Flip)
  if (velocity.x < 0 && scale.x > 0) {
    scale.x = -1;
  } else if (velocity.x > 0 && scale.x < 0) {
    scale.x = 1;
  }

  // Cek Status Gerakan Horizontal untuk Running vs Idle
  if (velocity.x != 0) {
    playerState = PlayerState.running;
  } else {
    playerState = PlayerState.idle;
  }

  // OVERRIDE: Cek Status Gerakan Vertikal
  // Logika ini akan menimpa idle/running jika player sedang di udara
  if (velocity.y < 0) {
    playerState = PlayerState.jumping;
  } else if (velocity.y > 0 && !isOnGround) {
    playerState = PlayerState.falling;
  }

  current = playerState;
}

void _updatePlayerMovement(double dt) {
  // 1. CEK LOMPATAN SECARA INSTAN (Frame-Perfect Jump)
  // Kita cek langsung ke state keyboard

if (hasJump && !_jumpPressed) {
    if (isOnGround || canDoubleJump) {
      _playerJump(dt);
    }
    _jumpPressed = true; 
  }

  if (!hasJump) {
    _jumpPressed = false;
  }

  // 2. HITUNG GERAKAN HORIZONTAL (Kanan/Kiri)
  velocity.x = horizontalMovement * moveSpeed;
  position.x += velocity.x * dt;

  // 3. VARIABLE JUMP HEIGHT (Lompat pendek jika spasi dilepas)
  if (!hasJump && velocity.y < 0) {
    velocity.y *= 0.5;
  }
}

void _playerJump(double dt) {
  if (isOnGround) {
    // Lompat normal dari tanah
    velocity.y = -_jumpForce;
    isOnGround = false;
    canDoubleJump = true;
  } else if (canDoubleJump) {
    // Ini yang Mas bro mau: Jika jatuh/di udara, langsung pakai kekuatan Double Jump
    velocity.y = -_doubleJumpForce;
    canDoubleJump = false; // Jatah habis
  }
}

void _applayGravity(double dt) {
  if (velocity.y > 0 && isOnGround) {
    isOnGround = false;
    canDoubleJump = true; 
  }

  // Logika Gravitasi Pintar
  double effectiveGravity = _gravity;

  if (velocity.y > 0) {
    // SAAT JATUH: Kecepatan jatuh ditambah secara progresif
    // Semakin tinggi velocity.y, semakin besar tambahan tarikannya
    effectiveGravity += (velocity.y * _fallAcceleration * dt);
    
    // Multiplier dasar agar tetap terasa berat sejak awal jatuh
    effectiveGravity *= 1.5; 
  }

  velocity.y += effectiveGravity;

  // Batasi kecepatan maksimal agar tidak tembus lantai (Terminal Velocity)
  velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
  
  position.y += velocity.y * dt;
}
  
void _checkHorizontalCollisions() {
  final hitbox = children.query<RectangleHitbox>().first;
  
  for (final block in collisionsBlocks) {
    if (!block.isPlatform) {
      if (checkCollisions(this, block)) {
        if (velocity.x > 0) { // Menabrak saat bergerak ke KANAN
          velocity.x = 0;
          
          // Rumus: Sisi kiri blok - setengah lebar hitbox - offset hitbox terhadap center
          // Karena anchor center, kita cukup pastikan tepi kanan kotak kuning menyentuh block.x
          double hitboxOffset = scale.x > 0 ? hitbox.x + hitbox.width : -hitbox.x;
          position.x = block.x - hitboxOffset;
          break;
        }
        
        if (velocity.x < 0) { // Menabrak saat bergerak ke KIRI
          velocity.x = 0;
          
          // Rumus: Sisi kanan blok + offset hitbox agar tepi kiri kotak kuning menyentuh block.x + width
          double hitboxOffset = scale.x > 0 ? hitbox.x : -(hitbox.x + hitbox.width);
          position.x = block.x + block.width - hitboxOffset;
          break;
        }
      }
    }
  }
}

  
void _checkVerticalCollisions() {
  final hitbox = children.query<RectangleHitbox>().first;

  for (final block in collisionsBlocks) {
    if (block.isPlatform) {
      if (checkCollisions(this, block)) {
        if (velocity.y > 0) {
          final playerBottom = position.y + hitbox.y + hitbox.height;
          if (playerBottom <= block.y + (velocity.y * 0.1)) {
            velocity.y = 0;
            position.y = block.y - hitbox.y - hitbox.height;
            isOnGround = true;
            canDoubleJump = false;
            break;
          }
        }
      }
    } else {
      if (checkCollisions(this, block)) {
        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = block.y - hitbox.y - hitbox.height;
          isOnGround = true;
          canDoubleJump = false;
          break;
        }
        if (velocity.y < 0) {
          velocity.y = 0;
          position.y = block.y + block.height - hitbox.y;
          break;
        }
      }
    }
  }
}
@override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Jika yang ditabrak adalah buah
    if (other is Fruits) {
      other.collidedWithPlayer();
    }
    super.onCollision(intersectionPoints, other);
  }
}
  