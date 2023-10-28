import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_scaler/image_scaler.dart';

const defaultSize = Size(200,200);
const defaultAreaRad = 1.0;
const defaultAlgorithm = ScaleAlgorithm.nni;

class TestApp extends StatefulWidget {
  final ui.Image round;
  final ui.Image shapes;
  final ui.Image lines;

  const TestApp(this.round, this.shapes, this.lines, {super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  ui.Size size = defaultSize;
  double areaRad = defaultAreaRad;
  ScaleAlgorithm algo = defaultAlgorithm;

  ScrollController horizontalScrollController = ScrollController();

  late Future<ui.Image> scaledRound;
  late Future<ui.Image> scaledShapes;
  late Future<ui.Image> scaledLines;

  void originalImages() {
    scaledRound = Future.value(widget.round);
    scaledShapes = Future.value(widget.shapes);
    scaledLines = Future.value(widget.lines);
  }

  void rescaleImages() {
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
                  ImageView(scaledRound),
                  ImageView(scaledShapes),
                  ImageView(scaledLines),
                ],
              ),
            ),
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
                value: size.width,
                onChanged: (v) {
                  setState(() {
                    size = Size(v, size.height);
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
                value: size.height,
                onChanged: (v) {
                  setState(() {
                    size = Size(size.width, v);
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

class ImageView extends StatelessWidget {
  late Future<ui.Image> image;

  ImageView(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: image,
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
          return RawImage(
            image: snapshot.data,
            fit: BoxFit.cover,
          );
        }
      },
    );
  }
}
