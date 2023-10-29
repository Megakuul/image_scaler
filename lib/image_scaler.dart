library image_scaler;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:image_scaler/types.dart';

import 'lanczos.dart';
import 'megak.dart';
import 'inni.dart';
import 'nni.dart';

enum ScaleAlgorithm {
  /// nni Algorithm
  ///
  ///
  /// Nearest Neighbour Interpolation is a very simple interpolation algorithm,
  /// it copies the pixels from the input image.
  ///
  ///
  /// Advantages:
  /// - Extremely fast as it copies the pixels directly from the input image.
  ///
  ///
  /// Limitations:
  /// - Pixels are very good visible in the edges, it does look really bad.
  nni,
  /// Inni Algorithm
  ///
  ///
  /// Improved Nearest Neighbour Interpolation is a very simple averaging algorithm,
  /// compared to the lanczos algorithm, it just takes all pixels from the window and
  /// calculates the average.
  ///
  ///
  /// Advantages:
  /// - Inni creates smooth and rounded Images
  ///
  /// - Algorithm performs around 40% faster then the lanczos implementation
  ///
  ///
  /// Limitations:
  /// - Algorithm cannot create sharp edges, it looks similar to anti-aliasing.
  inni,
  /// Megak Algorithm
  ///
  ///
  /// Megak algorithm is taking a window of the input image for every pixel,
  /// then it will determine a weight for the pixel. To calculate the weight for the pixel,
  /// it uses a simulated Lanczos kernel that produces a output simular to lanczos.
  /// Difference to Lanczos is that it only uses a conditional move and a single multiplication,
  /// instead of multiple sin and multiplication operations.
  ///
  ///
  /// Advantages:
  /// - Faster than lanczos.
  ///
  /// - Most images can be scaled in a quality similar to lanczos.
  ///
  /// - AreaSize can be adjusted without particle-issues (like lanczos currently has).
  ///
  /// Limitations:
  /// - Really slow
  ///
  /// - Maybe not compatible with all images / sizes.
  megak,
  /// Lanczos Algorithm
  ///
  ///
  /// Lanczos algorithm is taking a window of the input image for every pixel,
  /// then it will determine a weight for the pixel, this is based on the distance to the
  /// pixel of interest and is calculated by the mathematical lanczos algorithm.
  ///
  ///
  /// Advantages:
  /// - Lanczos creates really smooth and clean images.
  ///
  ///
  /// Limitations:
  /// - As tradeoff the lanczos is really slow as it performs multiple squareroot and sin operations.
  ///
  /// - Currently the algorithm only works properly with a areaSize of 1.
  ///
  /// - Due to my limited knowledge of mathematics,
  /// this algorithm may be underperforming, compared to professional implemented lanczos algorithms.
  lanczos
}

Future<Image> scale({required Image image, required IntSize newSize, required ScaleAlgorithm algorithm, int areaRadius=1}) async {
  const colorBlockSize = 4; // RGBA -> [255,255,255,255]
  final ByteData? byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
  if (byteData==null) {
    throw Exception("Invalid image. Cannot retrieve byte data!");
  }
  final Uint8List iByteBuf = byteData.buffer.asUint8List();
  final Uint8List oByteBuf = Uint8List(newSize.width.toInt() * newSize.height.toInt() * colorBlockSize);

  final oldSize = IntSize(image.width, image.height);

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