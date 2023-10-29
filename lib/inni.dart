import 'dart:typed_data';

import 'package:image_scaler/types.dart';

class _Vector {
  final int x;
  final int y;

  _Vector(this.x, this.y);
}

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
ScaleArguments inni(ScaleArguments args) {
  final oXScale = args.iSize.width / args.oSize.width;
  final oYScale = args.iSize.height / args.oSize.height;

  final maxAreaDiameter = (args.areaSize*2)+1;

  int iX;
  int iY;

  int oByteBufIndex;
  int iByteBufIndex;

  _Vector iAreaTLAnchor;

  int areaWidth;
  int areaHeight;

  Uint32List rgbStack;

  for (int x = 0; x < args.oSize.width; x++) {
    iX = (x*oXScale).round();
    for (int y = 0; y < args.oSize.height; y++) {
      iY = (y*oYScale).round();

      oByteBufIndex = (y * args.oSize.width + x) * args.colorBlockSize;

      // Top Left Area Anchor
      iAreaTLAnchor = _Vector(
        iX-args.areaSize<0 ? 0 : iX-args.areaSize,
        iY-args.areaSize<0 ? 0 : iY-args.areaSize
      );

      areaWidth
        = iAreaTLAnchor.x+maxAreaDiameter>args.iSize.width
            ? args.iSize.width-iAreaTLAnchor.x : maxAreaDiameter;
      areaHeight
        = iAreaTLAnchor.y+maxAreaDiameter>args.iSize.height
            ? args.iSize.height-iAreaTLAnchor.y : maxAreaDiameter;

      int avgDivider = 0;
      rgbStack = Uint32List(args.colorBlockSize);

      for (int wx = iAreaTLAnchor.x; wx < areaWidth+iAreaTLAnchor.x; wx++) {
        for (int wy = iAreaTLAnchor.y; wy < areaHeight+iAreaTLAnchor.y; wy++) {
          iByteBufIndex = (wy * args.iSize.width + wx) * args.colorBlockSize;
          avgDivider++;

          for (int i = 0; i < args.colorBlockSize; i++) {
            rgbStack[i]+=args.iByteBuf[iByteBufIndex+i];
          }
        }
      }

      for (int i = 0; i < args.colorBlockSize; i++) {
        args.oByteBuf[oByteBufIndex+i] = (rgbStack[i] / avgDivider).clamp(0, 255).round();
      }
    }
  }
  return args;
}