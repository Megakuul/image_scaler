library image_scaler;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:image_scaler/scalearg.dart';

import 'lanczos.dart';
import 'megak.dart';
import 'inni.dart';
import 'nni.dart';

enum ScaleAlgorithm {
  nni,
  inni,
  megak,
  lanczos
}

Future<Image> scale({required Image image, required Size newSize, required ScaleAlgorithm algorithm, int areaRadius=1}) async {
  const colorBlockSize = 4; // RGBA -> [255,255,255,255]
  final ByteData? byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
  if (byteData==null) {
    throw Exception("Invalid image. Cannot retrieve byte data!");
  }
  final Uint8List iByteBuf = byteData.buffer.asUint8List();
  final Uint8List oByteBuf = Uint8List(newSize.width.toInt() * newSize.height.toInt() * colorBlockSize);

  final oldSize = Size(image.width.toDouble(), image.height.toDouble());

  late ScaleArguments deserializedArgs;
  switch (algorithm) {
    case ScaleAlgorithm.nni:
      deserializedArgs = await compute(nni, ScaleArguments(iByteBuf, oByteBuf, oldSize, newSize, colorBlockSize, areaRadius));
      break;
    case ScaleAlgorithm.inni:
      deserializedArgs = await compute(inni, ScaleArguments(iByteBuf, oByteBuf, oldSize, newSize, colorBlockSize, areaRadius));
      break;
    case ScaleAlgorithm.megak:
      deserializedArgs = await compute(megak, ScaleArguments(iByteBuf, oByteBuf, oldSize, newSize, colorBlockSize, areaRadius));
      break;
    case ScaleAlgorithm.lanczos:
      deserializedArgs = await compute(lanczos, ScaleArguments(iByteBuf, oByteBuf, oldSize, newSize, colorBlockSize, areaRadius));
      break;
  }

  final Completer<Image> completer = Completer();
  decodeImageFromPixels(deserializedArgs.oByteBuf,
      deserializedArgs.oSize.width.toInt(),
      deserializedArgs.oSize.height.toInt(),
      PixelFormat.rgba8888, (Image output) {
        completer.complete(output);
      });

  return completer.future;
}