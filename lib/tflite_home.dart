// import 'dart:async';
// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_v2/tflite_v2.dart';

// class TFLiteHome extends StatefulWidget {
//   const TFLiteHome({Key? key}) : super(key: key);

//   @override
//   _TFLiteHomeState createState() => _TFLiteHomeState();
// }

// const String ssd = 'SSD MobileNet';
// const String yolo = 'Tiny YOLOv2';

// class _TFLiteHomeState extends State<TFLiteHome> {
//   String _model = ssd;
//   File? _image;

//   double? _imageWidth;
//   double? _imageHeight;

//   bool _busy = false;

//   List? _recognitions;

//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _controller = CameraController(
//       CameraDescription(
//         name: '',
//         lensDirection: CameraLensDirection.back,
//         sensorOrientation: 0,
//       ),
//       ResolutionPreset.medium,
//     );
//     _initializeControllerFuture = _controller.initialize();
//     _busy = true;
//     loadModel().then((val) {
//       setState(() {
//         _busy = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   selectFromImagePicker() async {
//     var imageRaw = await ImagePicker()
//         .pickImage(source: ImageSource.camera)
//         .then((value) => value!.path);

//     File? image = File(imageRaw);

//     if (image == null) return;
//     setState(() {
//       _busy = true;
//     });
//     predictImage(image);
//   }

//   void predictImage(var image) async {
//     if (image == null) return;

//     if (_model == yolo) {
//       yolov2Tiny(image);
//     } else
//       ssdMobileNet(image);

//     FileImage(image)
//         .resolve(const ImageConfiguration())
//         .addListener(ImageStreamListener((imageInfo, _) {
//       setState(() {
//         _imageWidth = imageInfo.image.width.toDouble();
//         _imageHeight = imageInfo.image.height.toDouble();
//       });
//     }));

//     setState(() {
//       _image = image;
//       _busy = false;
//     });
//   }

//   yolov2Tiny(var image) async {
//     var recognitions = await Tflite.detectObjectOnImage(
//         path: image.path,
//         model: "YOLO",
//         threshold: 0.3,
//         imageMean: 0.0,
//         imageStd: 125.0,
//         numResultsPerClass: 1);

//     setState(() {
//       _recognitions = recognitions!;
//     });
//   }

//   List<Widget> renderBoxes(Size screen) {
//     if (_recognitions == null) return [];

//     if (_imageWidth == null || _imageHeight == null) return [];
//     double factorX = screen.width;
//     double factorY = _imageHeight! / _imageHeight! * screen.width;

//     Color _blue = Colors.blue;
//     return _recognitions!
//         .map((re) => Positioned(
//               left: re['rect']['x'] * factorX,
//               top: re['rect']['y'] * factorY,
//               width: re['rect']['w'] * factorX,
//               height: re['rect']['h'] * factorY,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5),
//                   border: Border.all(
//                     color: Colors.blue,
//                     width: 3,
//                   ),
//                 ),
//                 child: Text(
//                   "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
//                   style: TextStyle(background: Paint()..color = _blue),
//                 ),
//               ),
//             ))
//         .toList();
//   }

//   ssdMobileNet(var image) async {
//     var recognitions = await Tflite.detectObjectOnImage(
      
//       model: "SSDMobileNet",
//       imageStd: 125,
//       threshold: 0.1,
//       imageMean: 125,
//         path: image.path, numResultsPerClass: 1);

//     setState(() {
//       _recognitions = recognitions!;
//     });
//   }

//   loadModel() async {
//     Tflite.close();
//     try {
//       String? res;
//       if (_model == yolo) {
//         res = await Tflite.loadModel(
//             model: 'assets/tflite/yolov2_tiny.tflite',
//             labels: 'assets/tflite/yolov2_tiny.txt');
//       } else {
//         res = await Tflite.loadModel(
//             model: 'assets/tflite/ssd_mobilenet.tflite',
//             labels: 'assets/tflite/ssd_mobilenet.txt');
//       }
//       print(res);
//     } on PlatformException {
//       print('Failed to load the model');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     List<Widget> stackChildren = [];

//     stackChildren.add(
//       Positioned(
//         left: 0.0,
//         top: 0.0,
//         width: size.width,
//         child: FutureBuilder<void>(
//           future: _initializeControllerFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               return CameraPreview(_controller);
//             } else {
//               return Center(child: CircularProgressIndicator());
//             }
//           },
//         ),
//       ),
//     );

//     stackChildren.addAll(renderBoxes(size));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('TensorFlow Lite Demo'),
//         centerTitle: true,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           try {
//             await _initializeControllerFuture;
//             final image = await _controller.takePicture();
//             predictImage(File(image.path));
//           } catch (e) {
//             print(e);
//           }
//         },
//         tooltip: 'Take a picture',
//         child: Icon(Icons.camera),
//       ),
//       body: Stack(
//         children: stackChildren,
//       ),
//     );
//   }
// }
