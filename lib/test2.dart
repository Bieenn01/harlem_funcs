// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart'; // Add camera dependency
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:fuzzywuzzy/fuzzywuzzy.dart' show partialRatio; // Use partialRatio from fuzzywuzzy

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CameraScreen(),
//     );
//   }
// }

// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   late List<CameraDescription> _cameras;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize camera controller
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     // Ensure that plugin services are initialized before calling the `cameras` function
//     WidgetsFlutterBinding.ensureInitialized();
//     // Retrieve the list of available cameras
//     _cameras = await availableCameras();
//     // Initialize camera controller
//     _controller = CameraController(
//       _cameras[0], // You can choose the camera here
//       ResolutionPreset.high,
//     );
//     // Initialize controller future
//     _initializeControllerFuture = _controller.initialize();
//     // Update the state once the camera is initialized
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_cameras.isEmpty) {
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text('Camera Feed')),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             // If the Future is complete, display the camera preview.
//             return CameraPreview(_controller);
//           } else {
//             // Otherwise, display a loading indicator.
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           try {
//             // Ensure that the camera is initialized.
//             await _initializeControllerFuture;

//             // Take a picture and extract text
//             XFile imageFile = await _controller.takePicture();
//             Uint8List imageBytes = await imageFile.readAsBytes();

//             // Convert image bytes to InputImage
//             InputImage inputImage = InputImage.fromBytes(
//               bytes: imageBytes,
//               metadata: InputImageData(
//                 size: Size(1920, 1080),
//                 imageRotation: InputImageRotation.rotation0deg,
//                 // The image format depends on the camera, you may need to adjust this
//                 // InputImageFormat.NV21 is just an example, use the appropriate format for your camera
//                 inputImageFormat: InputImageFormat.nv21,
//               ),
//             );

//             // Create an instance of TextDetector
//             final textDetector = GoogleMlKit.vision.textRecognizer();
//             // Process the input image
//             final Text text = await textDetector.processImage(inputImage);

//             // Process the detected text
//             String detectedText = text.text ?? "";
//             String bestMatch = findBestMatch(detectedText);

//             // Print or use the best match
//             print("Detected: $detectedText, Best Match: $bestMatch");

//             // Render boxes for object detection
//             // (You'll need to implement this part)

//           } catch (e) {
//             // If an error occurs, log the error to the console.
//             print(e);
//           }
//         },
//         child: Icon(Icons.camera_alt),
//       ),
//     );
//   }

//   String findBestMatch(String detectedText) {
//     // Predefined food supplement sizes
//     List<String> predefinedSizes = ["1.02kg", "284g"];

//     // Initialize best match
//     String bestMatch = "";
//     int bestRatio = 0;

//     // Find the best match
//     for (String size in predefinedSizes) {
//       int ratio = fuzzyMatch(detectedText, size);
//       if (ratio > bestRatio) {
//         bestRatio = ratio;
//         bestMatch = size;
//       }
//     }

//     return bestMatch;
//   }

//   int fuzzyMatch(String detectedText, String size) {
//     return partialRatio(detectedText, size); // Using partialRatio
//   }
// }
