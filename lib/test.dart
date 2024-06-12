import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ObjectDetectionScreen(),
    );
  }
}

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({Key? key}) : super(key: key);

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  var _recognitions;

    double? _imageWidth;
  double? _imageHeight;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[0], 
      ResolutionPreset.max,
    );
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    loadModel();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/tflite/yolov2_tiny.tflite",
      labels: "assets/tflite/yolov2_tiny.txt",
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

Future<void> _runModelOnFrame(CameraImage cameraImage) async {
  var recognitions = await Tflite.detectObjectOnFrame(
    bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
    model: "YOLO",
    imageHeight: cameraImage.height,
    imageWidth: cameraImage.width,
    imageMean: 127.5,
    imageStd: 127.5,
    rotation: 90,
    threshold: 0.1,
    asynch: true,
  );

  setState(() {
    _recognitions = recognitions;
    _imageWidth = cameraImage.width.toDouble(); 
    _imageHeight = cameraImage.height.toDouble(); 
  });

  print(_recognitions);
}


List<Widget> renderBoxes(Size screen) {
  if (_recognitions == null) return [];

  if (_imageWidth == null || _imageHeight == null) return [];

  double factorX = screen.width;
  double factorY = _imageHeight! / _imageHeight! * screen.width;

  Color _blue = Colors.blue;
  
  return _recognitions!.map<Widget>((re) {
    return Positioned(
      left: re['rect']['x'] * factorX,
      top: re['rect']['y'] * factorY,
      width: re['rect']['w'] * factorX,
      height: re['rect']['h'] * factorY,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.blue,
            width: 3,
          ),
        ),
        child: Text(
          "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
          style: TextStyle(background: Paint()..color = _blue),
        ),
      ),
    );
  }).toList();
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Object Detection ',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
    ),
    body: SingleChildScrollView(
      child: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                ...renderBoxes(MediaQuery.of(context).size), // Add rendered boxes to the stack
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    ),
    floatingActionButton: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              _controller.startImageStream((CameraImage cameraImage) {
                _runModelOnFrame(cameraImage);
              });
            } catch (e) {
              print('Error starting image stream: $e');
            }
          },
          child: const Icon(Icons.camera),
        ),
        const SizedBox(width: 10), // Adjust the spacing between buttons
        FloatingActionButton(
          onPressed: () {
            _controller.stopImageStream();
          },
          child: const Icon(Icons.stop),
        ),
      ],
    ),
  );
}


}
