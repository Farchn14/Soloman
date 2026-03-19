import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:soloman/components/background_tile.dart';
import 'package:soloman/components/collisions_block.dart';
import 'package:soloman/components/fruit.dart';
import 'package:soloman/components/player.dart';
import 'package:soloman/pixel_advanture.dart';

class Level extends World with HasGameReference<PixelAdvanture>{

  final String LevelName;
  final Player player;
  Level({required this.LevelName, required this.player});
  late TiledComponent level;
  late List<CollisionsBlock> collisionsBlocks =[];


  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$LevelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();



    return super.onLoad();
  }
  
  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer("Background");
    const double tileSize = 64; // Gunakan double untuk presisi

    // Hitung berapa banyak tile yang dibutuhkan untuk menutupi layar
    // Ditambah 1 atau 2 untuk cadangan saat bergulir
    final int numTilesY = (game.size.y / tileSize).ceil() + 1;
    final int numTilesX = (game.size.x / tileSize).ceil() + 1;

    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue("backgroundColor");

      for (int y = 0; y < numTilesY; y++) {
        for (int x = 0; x < numTilesX; x++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray',
            // Mulai dari -tileSize agar tidak terlihat kosong di atas saat bergulir ke bawah
            position: Vector2(x * tileSize, y * tileSize - tileSize),
          );
          add(backgroundTile);
        }
      }
    }
}
  
  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawn');
    if(spawnPointsLayer != null){
        for(final Spawn in spawnPointsLayer!.objects){
        switch (Spawn.class_) {
          case 'Player':
            player.position = Vector2(Spawn.x, Spawn.y);
            add(player);
            break;
            case'Fruits' :
            final fruit = Fruits(
              fruit: Spawn.name,
              position: Vector2(Spawn.x, Spawn.y),
              size: Vector2(Spawn.width, Spawn.height),
            );
            add(fruit);
            break;
          default:
        }
      }
    }
  }
  
  void _addCollisions() {
      final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

        if(collisionsLayer != null){
          for(final collisions in collisionsLayer.objects){
            switch (collisions.class_) {
              case 'Platform':
                final platform = CollisionsBlock(
                  position: Vector2(collisions.x, collisions.y),
                  size: Vector2(collisions.width, collisions.height),
                  isPlatform: true,
                );
                collisionsBlocks.add(platform);
                add(platform);
                break;
              default:
              final block = CollisionsBlock(
                  position: Vector2(collisions.x, collisions.y),
                  size: Vector2(collisions.width, collisions.height),
              );
              collisionsBlocks.add(block);
              add(block);
            }
          }
        }
    player.collisionsBlocks =collisionsBlocks;
  }
}