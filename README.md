# image_scaler

Light weight flutter library to rescale Images.

## Features

Provides following Algorithms:

| Algorithm                                       | Speed           | Quality   |
|-------------------------------------------------|-----------------|-----------|
| Nearest Neighbour Interpolation (nni)           | Extremely fast  | Bad       |
| Improved Nearest Neighbour Interpolation (inni) | Very fast       | Average   |
| Megak (megak)                                   | Average         | Very good |
| Lanczos (lanczos)                               | Slow            | Very good |

Calculations are carried out in a separate isolate, this will make sure the Main-Thread is not blocked.

ScaleAlgorithms are documented more detailed in the Dartdoc comments.

## Getting started

Add
```bash
flutter pub add image_scaler
```

Import
```dart
import 'package:image_scaler/image_scaler.dart';
import 'package:image_scaler/types.dart';
```

## Usage

Flutter Futurebuilder Example
```dart
final Future<ui.Image> = scale(
    image: widget.round,
    newSize: const IntSize(200, 200),
    algorithm: ScaleAlgorithm.megak,
    areaRadius: 2
);

class MyImage extends StatelessWidget {
  final Future<ui.Image> image;
  
  const MyImage(this.image);
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: image,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        } else {
          return RawImage(
            image: snapshot.data,
            fit: BoxFit.cover,
          );
        }
      },
    );
  }
}
```


Flutter Flame prerendered Sprite Example
```dart
// PlayerComponent.dart

Future<Image> prerenderSpriteComponent(Sprite sprite, Size size) async {
  final spriteComp = SpriteComponent(sprite: sprite);

  // Original Image
  final oiRecorder = PictureRecorder();
  final oiCanvas = Canvas(oiRecorder);
  spriteComp.render(oiCanvas);

  final oiImage = await oiRecorder.endRecording().toImage(
    sprite.srcSize.x.toInt(),
    sprite.srcSize.y.toInt(),
  );

  return await scale(oiImage, IntSize(size.width.toInt(), size.height.toInt()), ScaleAlgorithm.lanczos);
}

ui.Image? playerSpriteRendered;

@override
void onLoad() async {
  playerSpriteRendered = await prerenderSpriteComponent(
    playerSpriteSheet.getSprite(0, player.color),
    Size.fromRadius(player.rad),
  );
}

@override
void render(Canvas canvas) {
  super.render(canvas);

  if (playerSpriteRendered!=null) {
    canvas.drawImage(
      playerSpriteRendered!,
      Offset(-player.rad, -player.rad),
      Paint()
    );
  }
}
```

## Example

You will find an example application in the [Github Repository](https://github.com/Megakuul/image_scaler).