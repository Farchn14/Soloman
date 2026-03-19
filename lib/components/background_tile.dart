import 'dart:async';

import 'package:flame/components.dart';
import 'package:soloman/pixel_advanture.dart';

class BackgroundTile extends SpriteComponent with HasGameReference<PixelAdvanture>{
  final String color;
  BackgroundTile({this.color = 'Gray', 
      position,
    }): super (
      position : position,
    );

  final double scrollSpeed = 0.4;

@override
  FutureOr<void> onLoad() {
    priority = -1;
   size = Vector2.all(64.4);
   sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

@override
void update(double dt) {
  position.y += scrollSpeed;
  
  double tileSize = 64;
  // Jika tile sudah melewati batas bawah layar
  if (position.y >= game.size.y) {
    // Pindahkan kembali ke paling atas (di atas tile paling atas)
    position.y -= (game.size.y / tileSize).ceil() * tileSize + tileSize;
  }
  super.update(dt);
}

}