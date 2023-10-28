import 'dart:typed_data';
import 'dart:ui';

import 'package:image_scaler/scalearg.dart';

class _Vector {
  final int x;
  final int y;

  _Vector(this.x, this.y);
}

ScaleArguments inni(ScaleArguments args) {
  final oXScale = args.iSize.width / args.oSize.width;
  final oYScale = args.iSize.height / args.oSize.height;

  for (int x = 0; x < args.oSize.width; x++) {
    final iX = (x*oXScale).round();
    for (int y = 0; y < args.oSize.height; y++) {
      final iY = (y*oYScale).round();

      final oByteBufIndex = (y * args.oSize.width.toInt() + x) * args.colorBlockSize;

      // Top Left Area Anchor
      final iAreaTLAnchor = _Vector(
        iX-args.areaSize<0 ? 0 : iX-args.areaSize,
        iY-args.areaSize<0 ? 0 : iY-args.areaSize
      );

      final maxAreaDiameter = (args.areaSize*2)+1;
      final areaWidth
        = iAreaTLAnchor.x+maxAreaDiameter>args.iSize.width
            ? args.iSize.width-iAreaTLAnchor.x : maxAreaDiameter;
      final areaHeight
        = iAreaTLAnchor.y+maxAreaDiameter>args.iSize.height
            ? args.iSize.height-iAreaTLAnchor.y : maxAreaDiameter;

      int avgDivider = 0;
      final Uint32List rgbStack = Uint32List(args.colorBlockSize);

      for (int wx = iAreaTLAnchor.x; wx < areaWidth+iAreaTLAnchor.x; wx++) {
        for (int wy = iAreaTLAnchor.y; wy < areaHeight+iAreaTLAnchor.y; wy++) {
          final iByteBufIndex = (wy * args.iSize.width.toInt() + wx) * args.colorBlockSize;
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