import 'dart:math';
import 'dart:typed_data';

import 'package:image_scaler/types.dart';

class _Vector {
  final int x;
  final int y;

  _Vector(this.x, this.y);
}

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
ScaleArguments megak(ScaleArguments args) {
  final oXScale = args.iSize.width / args.oSize.width;
  final oYScale = args.iSize.height / args.oSize.height;

  final mkXScale = args.iSize.width > args.oSize.width ? oXScale : 1;
  final mkYScale = args.iSize.height > args.oSize.height ? oYScale : 1;

  final maxAreaDiameter = (args.areaSize*2)+1;

  double iX;
  double iY;

  int oByteBufIndex;
  int iByteBufIndex;

  _Vector iAreaTLAnchor;
  _Vector iAreaBRAnchor;

  double tWeight;
  Uint32List rgbStack;

  double dx;
  double dy;
  double d;
  double curWeight;

  for (int x = 0; x < args.oSize.width; x++) {
    iX = x * oXScale;
    for (int y = 0; y < args.oSize.height; y++) {
      iY = y * oYScale;

      oByteBufIndex = (y * args.oSize.width + x) * args.colorBlockSize;

      // Top Left Area Anchor
      iAreaTLAnchor = _Vector(
          (iX-args.areaSize<0 ? 0 : iX-args.areaSize).toInt(),
          (iY-args.areaSize<0 ? 0 : iY-args.areaSize).toInt()
      );
      // Bottom Right Area Anchor
      iAreaBRAnchor = _Vector(
        (iAreaTLAnchor.x+maxAreaDiameter).clamp(0, args.iSize.width),
        (iAreaTLAnchor.y+maxAreaDiameter).clamp(0, args.iSize.height),
      );

      tWeight = 0;
      rgbStack = Uint32List(args.colorBlockSize);

      for (int iXArea = iAreaTLAnchor.x; iXArea < iAreaBRAnchor.x; iXArea++) {
        for (int iYArea = iAreaTLAnchor.y; iYArea < iAreaBRAnchor.y; iYArea++) {
          iByteBufIndex = (iYArea * args.iSize.width + iXArea) * args.colorBlockSize;

          dx = (iXArea - iX).abs() / mkXScale;
          dy = (iYArea - iY).abs() / mkYScale;
          d = sqrt(dx * dx + dy * dy);
          curWeight = _kernel(d, args.areaSize);

          for (int i = 0; i < args.colorBlockSize; i++) {
            rgbStack[i] += (args.iByteBuf[iByteBufIndex + i] * curWeight).round();
          }

          tWeight += curWeight;
        }
      }

      for (int i = 0; i < args.colorBlockSize; i++) {
        args.oByteBuf[oByteBufIndex + i] = (rgbStack[i] / tWeight).clamp(0, 255).round();
      }
    }
  }
  return args;
}

double _kernel(double x, int a) {
  if (x == 0) return 1;
  if (x.abs() >= a) return 0;
  return x == x.truncateToDouble() ? a - x : (a - x) * 0.6;
}