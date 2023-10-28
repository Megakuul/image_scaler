import 'dart:typed_data';
import 'dart:ui';

class ScaleArguments {
  final Uint8List iByteBuf;
  final Uint8List oByteBuf;
  final Size iSize;
  final Size oSize;
  final int colorBlockSize;
  final int areaSize;

  ScaleArguments(this.iByteBuf, this.oByteBuf, this.iSize, this.oSize, this.colorBlockSize, this.areaSize);
}