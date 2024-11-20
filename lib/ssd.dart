// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:tflite_v2/tflite_v2.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   List<CameraDescription> cameras = await availableCameras();
//   runApp(ObjectDetector(cameras));
// }

// class ObjectDetector extends StatefulWidget {
//   final List<CameraDescription> cameras;

//   ObjectDetector(this.cameras);

//   @override
//   _ObjectDetectorState createState() => _ObjectDetectorState();
// }

// class _ObjectDetectorState extends State<ObjectDetector> {
//   late CameraController _controller;
//   late List<dynamic> _recognitions;
//   late int _imageHeight = 0;
//   late int _imageWidth = 0;
//   late bool _isDetecting = false;
//   late Future<void> _initializeControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllerFuture = initializeController();
//   }

//   Future<void> initializeController() async {
//     await Tflite.loadModel(
//       model: "assets/ssd_mobilenet.tflite",
//       labels: "assets/ssd_mobilenet.txt",
//     );

//     _controller = CameraController(
//       widget.cameras[0],
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );

//     await _controller.initialize();

//     _controller.startImageStream((CameraImage img) {
//       if (!_isDetecting) {
//         _isDetecting = true;
//         Tflite.detectObjectOnFrame(
//           bytesList: img.planes.map((plane) {
//             return plane.bytes;
//           }).toList(),
//           model: "SSDMobileNet",
//           imageHeight: img.height,
//           imageWidth: img.width,
//           imageMean: 127.5,
//           imageStd: 127.5,
//           numResultsPerClass: 1,
//           threshold: 0.4,
//         ).then((recognitions) {
//           setState(() {
//             _recognitions = recognitions!;
//             _isDetecting = false;
//           });
//         });
//       }
//     });
//   }

// @override
// Widget build(BuildContext context) {
//   return MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(
//         title: Text('Object Detector'),
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Stack(
//               children: [
//                 Positioned.fill(
//                   child: CameraPreview(_controller),
//                 ),
//                 BoundingBox(
//                   recognitions: _recognitions,
//                   imageHeight: _imageHeight,
//                   imageWidth: _imageWidth,
//                 ),
//               ],
//             );
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     ),
//   );
// }


//   @override
//   void dispose() {
//     _controller.dispose();
//     Tflite.close();
//     super.dispose();
//   }
// }

// class BoundingBox extends StatelessWidget {
//   final List<dynamic> recognitions;
//   final int imageHeight;
//   final int imageWidth;

//   BoundingBox({
//     required this.recognitions,
//     required this.imageHeight,
//     required this.imageWidth,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: ObjectDetectorPainter(
//         recognitions,
//         imageHeight,
//         imageWidth,
//       ),
//     );
//   }
// }

// class ObjectDetectorPainter extends CustomPainter {
//   final List<dynamic> recognitions;
//   final int imageHeight;
//   final int imageWidth;

//   ObjectDetectorPainter(
//     this.recognitions,
//     this.imageHeight,
//     this.imageWidth,
//   );

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Implement drawing logic here
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
