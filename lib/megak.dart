import 'dart:math';
import 'dart:typed_data';

import 'package:image_scaler/scalearg.dart';

class _Vector {
  final int x;
  final int y;

  _Vector(this.x, this.y);
}

ScaleArguments megak(ScaleArguments args) {
  final oXScale = args.iSize.width / args.oSize.width;
  final oYScale = args.iSize.height / args.oSize.height;

  for (int x = 0; x < args.oSize.width; x++) {
    final iX = (x*oXScale).round();
    for (int y = 0; y < args.oSize.height; y++) {
      final iY = (y*oYScale).round();

      final oByteBufIndex = (y * args.oSize.width.toInt() + x) * args.colorBlockSize;

      final maxAreaDiameter = (args.areaSize*2)+1;

      // Top Left Area Anchor
      final iAreaTLAnchor = _Vector(
          iX-args.areaSize<0 ? 0 : iX-args.areaSize,
          iY-args.areaSize<0 ? 0 : iY-args.areaSize
      );
      // Bottom Right Area Anchor
      final iAreaBRAnchor = _Vector(
        (iAreaTLAnchor.x+maxAreaDiameter).clamp(0, args.iSize.width).toInt(),
        (iAreaTLAnchor.y+maxAreaDiameter).clamp(0, args.iSize.height).toInt(),
      );

      double tWeight = 0;
      final Uint32List rgbStack = Uint32List(args.colorBlockSize);

      for (int iXArea = iAreaTLAnchor.x; iXArea < iAreaBRAnchor.x; iXArea++) {
        for (int iYArea = iAreaTLAnchor.y; iYArea < iAreaBRAnchor.y; iYArea++) {
          final iByteBufIndex = (iYArea * args.iSize.width.toInt() + iXArea) * args.colorBlockSize;

          final dx = (iXArea - iX).abs() / oXScale;
          final dy = (iYArea - iY).abs() / oYScale;
          final distance = sqrt(dx * dx + dy * dy);
          // TODO: Implement logic
          final weight = 0.5;

          for (int i = 0; i < args.colorBlockSize; i++) {
            rgbStack[i]+=args.iByteBuf[iByteBufIndex+i];
          }

          tWeight += weight;
        }
      }

      for (int i = 0; i < args.colorBlockSize; i++) {
        args.oByteBuf[oByteBufIndex+i] = (rgbStack[i] / tWeight).clamp(0, 255).round();
      }
    }
  }
  return args;
}