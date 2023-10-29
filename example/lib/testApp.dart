import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_scaler/image_scaler.dart';
import 'package:image_scaler/types.dart';

const defaultSize = IntSize(200,200);
const defaultAreaRad = 1.0;
const defaultAlgorithm = ScaleAlgorithm.lanczos;

class TestApp extends StatefulWidget {
  final ui.Image round;
  final ui.Image shapes;
  final ui.Image lines;

  const TestApp(this.round, this.shapes, this.lines, {super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  IntSize size = defaultSize;
  double areaRad = defaultAreaRad;
  ScaleAlgorithm algo = defaultAlgorithm;

  ScrollController horizontalScrollController = ScrollController();

  late Future<ui.Image> scaledRound;
  late Future<ui.Image> scaledShapes;
  late Future<ui.Image> scaledLines;

  late DateTime timeBuf;

  final ValueNotifier<Duration> roundDurNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> shapesDurNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> linesDurNotifier = ValueNotifier(Duration.zero);

  void startTimer() {
    timeBuf = DateTime.now();
  }

  void originalImages() {
    scaledRound = Future.value(widget.round);
    scaledShapes = Future.value(widget.shapes);
    scaledLines = Future.value(widget.lines);
    startTimer();
  }

  void rescaleImages() {
    scaledRound = scale(
        image: widget.round,
        newSize: const IntSize(200, 200),
        algorithm: ScaleAlgorithm.megak,
        areaRadius: 2
    );
    scaledRound = scale(
      image: widget.round,
      newSize: size,
      algorithm: algo,
      areaRadius: areaRad.toInt()
    );
    scaledShapes = scale(
      image: widget.shapes,
      newSize: size,
      algorithm: algo,
      areaRadius: areaRad.toInt()
    );
    scaledLines = scale(
      image: widget.lines,
      newSize: size,
      algorithm: algo,
      areaRadius: areaRad.toInt()
    );
    startTimer();
  }

  @override
  void initState() {
    originalImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(66,69,73, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ImageView(scaledRound, roundDurNotifier, timeBuf),
                  ImageView(scaledShapes, shapesDurNotifier, timeBuf),
                  ImageView(scaledLines, linesDurNotifier, timeBuf),
                ],
              ),
            ),
          ),
          const Text(
            "Duration (ms):",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                width: 75,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ValueListenableBuilder(
                  valueListenable: roundDurNotifier,
                  builder: (context, value, child) {
                    return Text(
                      "${value.inMilliseconds.round()}",
                      textAlign: TextAlign.center,
                    );
                  },
                )
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                width: 75,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ValueListenableBuilder(
                  valueListenable: shapesDurNotifier,
                  builder: (context, value, child) {
                    return Text(
                      "${value.inMilliseconds.round()}",
                      textAlign: TextAlign.center,
                    );
                  },
                )
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                width: 75,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ValueListenableBuilder(
                  valueListenable: linesDurNotifier,
                  builder: (context, value, child) {
                    return Text(
                      "${value.inMilliseconds.round()}",
                      textAlign: TextAlign.center,
                    );
                  },
                )
              )
            ]
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Slider(
                label: "AreaRadius: $areaRad",
                max: 10,
                min: 0,
                divisions: 10,
                value: areaRad,
                onChanged: (v) {
                  setState(() {
                    areaRad = v;
                  });
                },
                onChangeEnd: (v) {
                  rescaleImages();
                  setState(() {});
                },
              ),
              Slider(
                label: "Width: ${size.width}",
                max: 1000,
                min: 1,
                divisions: 999,
                value: size.width.toDouble(),
                onChanged: (v) {
                  setState(() {
                    size = IntSize(v.toInt(), size.height);
                  });
                },
                onChangeEnd: (v) {
                  rescaleImages();
                  setState(() {});
                },
              ),
              Slider(
                label: "Height: ${size.height}",
                max: 1000,
                min: 1,
                divisions: 999,
                value: size.height.toDouble(),
                onChanged: (v) {
                  setState(() {
                    size = IntSize(size.width, v.toInt());
                  });
                },
                onChangeEnd: (v) {
                  rescaleImages();
                  setState(() {});
                },
              ),
              DropdownButton(
                dropdownColor: Colors.grey,
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold
                ),
                value: algo,
                hint: const Text('Scale Algorithm'),
                items: ScaleAlgorithm.values.map((ScaleAlgorithm al) {
                  return DropdownMenuItem<ScaleAlgorithm>(
                    value: al,
                    child: Text(al.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (ScaleAlgorithm? newAl) {
                  setState(() {
                    algo = newAl!;
                    rescaleImages();
                  });
                },
              )
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        tooltip: "Reset",
        onPressed: () {
          originalImages();
          setState(() {
            size = defaultSize;
            areaRad = defaultAreaRad;
            algo = defaultAlgorithm;
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class ImageView extends StatefulWidget {
  final Future<ui.Image> image;
  final ValueNotifier<Duration> durationNotifier;
  final DateTime timeBuf;

  const ImageView(this.image, this.durationNotifier, this.timeBuf, {Key? key}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  bool _shouldUpdateDuration = true;

  @override
  void didUpdateWidget(ImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _shouldUpdateDuration = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: widget.image,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 3,
                maxWidth: MediaQuery.of(context).size.width / 4
            ),
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
          );
        } else {
          if (_shouldUpdateDuration) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.durationNotifier.value = DateTime.now().difference(widget.timeBuf);
              _shouldUpdateDuration = false;  // Reset flag to prevent further updates until image changes again.
            });
          }
          return RawImage(
            image: snapshot.data,
            fit: BoxFit.cover,
          );
        }
      },
    );
  }
}

