import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui' as ui;

import 'testApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ui.Image roundAsset = await loadAssetImage("assets/round.png");
  ui.Image shapeAsset = await loadAssetImage("assets/shapes.png");
  ui.Image lineAsset = await loadAssetImage("assets/lines.png");

  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightGreen
      ),
      home: TestApp(roundAsset, shapeAsset, lineAsset)
    )
  );
}

Future<ui.Image> loadAssetImage(String assetPath) async {
  ByteData data = await rootBundle.load(assetPath);
  final List<int> bytes = data.buffer.asUint8List();
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(Uint8List.fromList(bytes), (ui.Image img) {
    completer.complete(img);
  });

  return completer.future;
}