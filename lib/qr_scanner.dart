import 'dart:typed_data';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class WidgetQrScanner extends StatefulWidget {
  const WidgetQrScanner({super.key});
  @override
  State<WidgetQrScanner> createState() => _WidgetQrScannerState();
}

class _WidgetQrScannerState extends State<WidgetQrScanner> {
  String scannedText = '';
  String latitude = '';
  String longitude = '';

  Future<void> _openGoogleMaps(String lat, String lng) async {
    final Uri googleMapsUri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Google Maps with URI: $googleMapsUri';
    }
  }

  Future<void> _openWaze(String lat, String lng) async {
    final Uri wazeUri = Uri.parse("waze://?ll=$lat,$lng&navigate=yes");
    if (await canLaunchUrl(wazeUri)) {
      await launchUrl(wazeUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Waze with URI: $wazeUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Revised Default QR Scanner'),
        backgroundColor: Colors.blue,
      ),
      body: Builder(builder: (BuildContext scaffoldContext) {
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
                          bottomBarText: "Scan QR Code",
                          validator: (value) {
                            return value.contains(RegExp(r'(\w+)'), 1);
                          },
                          canPop: true,
                          onScan: (String value) async {
                            debugPrint("Scanned QR Code: $value");
                            Position position =
                                await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );
                            setState(() {
                              scannedText = value;
                              latitude = position.latitude.toString();
                              longitude = position.longitude.toString();
                            });

                            // Show a dialog using scaffoldContext
                            if (scaffoldContext.mounted) {
                              showDialog(
                                context: scaffoldContext,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Open Navigation'),
                                    content: Text(
                                        'Choose an app to navigate to this location:'),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _openGoogleMaps(
                                              latitude, longitude);
                                        },
                                        child: Text('Google Maps'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _openWaze(latitude, longitude);
                                        },
                                        child: Text('Waze'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          onDetect: (capture) {
                            final List<Barcode> scannedText = capture.barcodes;
                            for (final barcode in scannedText) {
                              debugPrint('Barcode found! ${barcode.rawValue}');
                            }
                          },
                          onDispose: () {
                            debugPrint('Barcode scanner disposed');
                          },
                          controller: MobileScannerController(
                            detectionSpeed: DetectionSpeed.noDuplicates,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Scan Here'),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10),
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
