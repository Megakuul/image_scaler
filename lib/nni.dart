import 'package:image_scaler/scalearg.dart';

ScaleArguments nni(ScaleArguments args) {
  final oXScale = args.iSize.width / args.oSize.width;
  final oYScale = args.iSize.height / args.oSize.height;

  for (int x = 0; x < args.oSize.width; x++) {
    for (int y = 0; y < args.oSize.height; y++) {
      final oByteBufIndex = (y * args.oSize.width.toInt() + x) * args.colorBlockSize;

      final iByteBufIndex = (
          (y * oYScale).round() * args.iSize.width.toInt() + (x * oXScale).round()
      ) * args.colorBlockSize;

      for (int i = 0; i < args.colorBlockSize; i++) {
        args.oByteBuf[oByteBufIndex+i] = args.iByteBuf[iByteBufIndex+i];
      }
    }
  }
  return args;
}