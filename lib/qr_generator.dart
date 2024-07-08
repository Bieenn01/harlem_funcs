import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator extends StatefulWidget {
  const QRGenerator({Key? key}) : super(key: key);

  @override
  State<QRGenerator> createState() => _QRGeneratorState();
}

class _QRGeneratorState extends State<QRGenerator> {
  String data = "";
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

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
                "Generate and Print QR Code",
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> generateAndPrintQRCode() async {
    try {
      // Generate QR code image data
      final qrImageData = await QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: false,
        color: Colors.black,
        emptyColor: Colors.white,
      ).toImageData(300.0, format: ImageByteFormat.png);

      if (qrImageData == null) {
        print("Error: QR code image data is null");
        return;
      }

      String base64Image = base64Encode(qrImageData.buffer.asUint8List());

      if (base64Image.isEmpty) {
        print("Error: Base64 conversion failed");
        return;
      }

      Map<String, dynamic> config = {
        'align': 'center',
      };

      List<LineText> lines = [
        LineText(
          type: LineText.TYPE_TEXT,
          content: 'Scan this $data',
          align: LineText.ALIGN_CENTER,
        ),
        LineText(
          type: LineText.TYPE_IMAGE,
          content: base64Image,
          align: LineText.ALIGN_CENTER,
          width: 80,
          height: 80,
        ),
      ];

      await bluetoothPrint.printReceipt(config, lines);
      print("QR code printed successfully");
    } catch (e) {
      print("Error generating and printing QR code: $e");
      // Handle specific errors here if needed
      rethrow; // Ensure the error propagates up for further analysis
    }
  }
}

class AppStyle {
  static Color primaryColor = Color(0xFF222222);
  static Color textInputColor = Color(0xFF404040);
  static Color accentColor = Color(0xFF4c90d2);
}
