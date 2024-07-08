import 'dart:io';
import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator extends StatefulWidget {
  const QRGenerator({Key? key}) : super(key: key);

  @override
  State<QRGenerator> createState() => _QRGeneratorState();
}

class _QRGeneratorState extends State<QRGenerator> {
  String data = "";
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("QR Code Generator"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: AppStyle.primaryColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Center(
              child: QrImageView(
                data: data,
                backgroundColor: Colors.white,
                version: QrVersions.auto,
                size: 300.0,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            SingleChildScrollView(
              child: Container(
                width: 300.0,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      data = value;
                    });
                  },
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type the Data",
                    filled: true,
                    fillColor: AppStyle.textInputColor,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            RawMaterialButton(
              onPressed: generateAndPrintQRCode,
              fillColor: AppStyle.accentColor,
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(
                horizontal: 36.0,
                vertical: 16.0,
              ),
              child: Text(
                "Generate QR Code",
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> generateAndPrintQRCode() async {
  try {
    final qrImageData = await QrPainter(
      data: data, 
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
      emptyColor: Colors.white,
    )
    .toImageData(80.0); 

    return bluetooth.printImageBytes(qrImageData!.buffer.asUint8List());

      // direct print from QrCodeViewer
      // await bluetooth.printQRcode(data,120,120,150);
          
      // ByteData bytesAsset = await rootBundle.load("assets/images/250by250.png");
      // Uint8List imageBytesFromAsset = bytesAsset.buffer.asUint8List();

      // await bluetooth.printImageBytes(imageBytesFromAsset); 

    } catch (e) {
      print("Error printing QR code: $e");
      rethrow;
    }
  }

}

class AppStyle {
  static Color primaryColor = Color(0xFF222222);
  static Color textInputColor = Color(0xFF404040);
  static Color accentColor = Color(0xFF4c90d2);
}
