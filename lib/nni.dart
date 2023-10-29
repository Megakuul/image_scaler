import 'package:image_scaler/types.dart';

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
ScaleArguments nni(ScaleArguments args) {
  final oXScale = (args.iSize.width / args.oSize.width);
  final oYScale = (args.iSize.height / args.oSize.height);

  int oByteBufIndex;
  int iByteBufIndex;

  for (int x = 0; x < args.oSize.width; x++) {
    for (int y = 0; y < args.oSize.height; y++) {
      oByteBufIndex = (y * args.oSize.width + x) * args.colorBlockSize;

      iByteBufIndex = (
          (y * oYScale).clamp(0, args.iSize.height - 1).round() * args.iSize.width + (x * oXScale).clamp(0, args.iSize.width-1).round()
      ) * args.colorBlockSize;

      for (int i = 0; i < args.colorBlockSize; i++) {
        args.oByteBuf[oByteBufIndex+i] = args.iByteBuf[iByteBufIndex+i];
      }
    }
  }

  return args;
}