import 'dart:typed_data';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class WidgetQrScanner extends StatefulWidget {
  const WidgetQrScanner({super.key});
  @override
  State<WidgetQrScanner> createState() => _WidgetQrScannerState();
}

class _WidgetQrScannerState extends State<WidgetQrScanner> {
  String? code;
  String scannedText = '';
  String latitude = '';
  String longitude = '';

@override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Revised Default Qr Scanner'),
            ],
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Builder(builder: (context) {
        return Material(
          child: Stack(
            children: [
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AiBarcodeScanner(
                          showOverlay: true,
                          // scanWindow: Rect.fromLTRB(
                          //   MediaQuery.of(context).size.width * 0.2, // left
                          //   MediaQuery.of(context).size.height * 0.3, // top
                          //   MediaQuery.of(context).size.width * 0.8, // right
                          //   MediaQuery.of(context).size.height * 0.7, // bottom
                          // ),
                          bottomBarText: "Scan QR Code",
                          validator: (value) {
                            return value.contains(RegExp(r'(\w+)'), 1);
                          },
                          canPop: true,
                          onScan: (String value) async {
                            debugPrint(value);
                            Position position = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high);
                            setState((){
                              scannedText = value;
                              latitude = position.latitude.toString();
                              longitude = position.longitude.toString();
                            });
                          },
                          onDetect: (capture) {
                            final List<Barcode> scannedText = capture.barcodes;
                            final Uint8List? image = capture.image;
                            for (final barcode in scannedText) {
                              debugPrint('Barcode found! ${barcode.rawValue}');
                            }
                          },
                          onDispose: () {
                            debugPrint('Barcode scanner disposed');
                          },
                          controller: MobileScannerController(
                            detectionSpeed: DetectionSpeed.noDuplicates
                          ),
                        )
                      )
                    );
                  },                      
                  icon: Icon(Icons.camera_alt_rounded),
                  label: Text('Scan Here'),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.black54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Scanned Text: $scannedText",
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Latitude: $latitude",
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Longitude: $longitude",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
