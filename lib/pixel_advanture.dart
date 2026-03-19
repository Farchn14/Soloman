import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:soloman/components/player.dart';
import 'package:soloman/components/level.dart';

class PixelAdvanture extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks{

  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  Player player = Player(character: 'Virtual Guy');
  late JoystickComponent joystik;
  bool showJoystik = false;


  @override
  FutureOr<void> onLoad() async {

  await images.loadAllImages();

    final world = Level(
    player: player,
    LevelName: 'Level02',
  );

    cam = CameraComponent.withFixedResolution (world: world, width:  640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam,world]);
  if(showJoystik){

  addJoystik();
  }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // LIMIT DT: Jika game lag, jangan biarkan dt lebih dari 1/60 detik
    // Ini mencegah lompatan menjadi terlalu tinggi saat lag.
    final double fixedDt = dt.clamp(0, 1 / 60);
    if(showJoystik){
    updateJoystik();
    }
    super.update(fixedDt);
  }
  
  void addJoystik() {
    joystik = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystik.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystik);
  }
  
  void updateJoystik() {
    switch (joystik.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:  
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement =  0;
        break;
    }
  }
}