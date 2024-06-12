import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ImageConverter extends StatefulWidget {
  @override
  _ImageConverterState createState() => _ImageConverterState();
}

class _ImageConverterState extends State<ImageConverter> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _images = [];
  bool _isConverting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image to PDF"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _isConverting ? null : () => convertImagesToPDF(),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "gallery",
            child: Icon(Icons.add),
            onPressed: _isConverting ? null : getImageFromGallery,
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "camera",
            child: Icon(Icons.camera_alt),
            onPressed: _isConverting ? null : getImageFromCamera,
          ),
        ],
      ),
      body: _images.isNotEmpty
        ? ListView.builder(
          itemCount: _images.length,
          itemBuilder: (context, index) => Container(
            height: 400,
            width: double.infinity,
            margin: EdgeInsets.all(8),
            child: Image.file(
              _images[index],
              fit: BoxFit.cover,
            ),
          ),
        )
      : const Center(
        child: Text(
          "No images selected",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      } else {
        print('No image selected');
      }
    });
  }

  Future<void> getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      } else {
        print('No image selected');
      }
    });
  }

  Future<void> convertImagesToPDF() async {
    setState(() {
      _isConverting = true;
    });

    try {
      if (_images.isEmpty) {
        throw Exception("No images selected.");
      }

      for (var img in _images) {
        final image = pw.MemoryImage(img.readAsBytesSync());

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image));
            },
          ),
        );
      }

      await savePDF(); // Save PDF after adding pages
    } catch (e) {
      showPrintedMessage('Error', e.toString());
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  Future<void> savePDF() async {
  try {
    final dir = Directory('/storage/emulated/0/Download');
    bool hasExisted = await dir.exists();
    if (!hasExisted) {
      dir.create(recursive: true);
    }

    final file = File("${dir.path}/LiveCam1.pdf");
    await file.writeAsBytes(await pdf.save());

    showPrintedMessage('Success', 'PDF saved to Download folder');
  } catch (e) {
    showPrintedMessage('Error', e.toString());
  }
}



  void showPrintedMessage(String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
