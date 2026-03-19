import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soloman/pixel_advanture.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  PixelAdvanture game = PixelAdvanture();
  runApp(GameWidget(game: kDebugMode ? PixelAdvanture() : game));
}

