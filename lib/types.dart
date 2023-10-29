import 'dart:typed_data';

class IntSize {
  final int width;
  final int height;

  const IntSize(this.width, this.height);
}

class ScaleArguments {
  final Uint8List iByteBuf;
  final Uint8List oByteBuf;
  final IntSize iSize;
  final IntSize oSize;
  final int colorBlockSize;
  final int areaSize;

  ScaleArguments(this.iByteBuf, this.oByteBuf, this.iSize, this.oSize, this.colorBlockSize, this.areaSize);
}