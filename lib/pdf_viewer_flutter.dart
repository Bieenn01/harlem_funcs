import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harlem/others/converter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:printing/printing.dart';
import 'package:ftpconnect/ftpconnect.dart';

class PdfViewerFlutter extends StatefulWidget {
  @override
  _PdfViewerFlutter createState() => _PdfViewerFlutter();
}

class _PdfViewerFlutter extends State<PdfViewerFlutter> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late FTPConnect ftpConnect;
  bool _isConnected = false;
  // String fileName = 'test/pdf/A-5.pdf';
  String fileName = 'test/pdf';

  @override
  void initState() {
    super.initState();
    connectFTP();
  }

  Future<void> connectFTP() async {
    ftpConnect = FTPConnect(
      '10.0.0.11',
      user: 'root',
      pass: 'alpha',
      securityType: SecurityType.FTP,
      showLog: true,
    );
    try {
      await ftpConnect.connect();
      showToast('FTP Log: Connected.');
      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      showToast('FTP Log: Connection failed - $e');
    }
  }

  Future<void> downloadAndPreviewPDF() async {
    if (!_isConnected) {
      showToast('FTP Log: Not connected.');
      return;
    }
    try {
      await ftpConnect.connect();
      Uint8List? fileData = await ftpConnect.downloadDirectory(fileName, Directory('/storage/emulated/0/Download')) as Uint8List?;
      if (fileData != null) {
        await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => SafeArea(
              child: PdfPreview(
                build: (format) => fileData,
              ),
            ),
          ),
        );
      } else {
        showToast('FTP Log: Failed to download PDF file.');
      }
    } catch (e) {
      showToast('FTP Log: Error - $e');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pdf Viewer Flutter'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.black,
              semanticLabel: 'Bookmark',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.wifi_tethering_rounded,
              color: Colors.black,
              semanticLabel: 'Print',
            ),
            onPressed: downloadAndPreviewPDF,
          ),
        ],
      ),
      body: Center(
        child: Card(
          child: Row(
            children: [
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result != null && result.files.isNotEmpty) {
                          PlatformFile file = result.files.first;
                          File pickedFile = File(file.path!);
                          Uint8List fileData = await pickedFile.readAsBytes();
                          Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) => SafeArea(
                                child: PdfPreview(
                                  build: (format) => fileData,
                                ),
                              ),
                            ),
                          );
                        } else {
                          showToast('Error: No file selected.');
                        } 
                      } catch (e) {
                        showToast('Error picking file: $e');
                      }
                    },
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('Pick PDF File'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>  ImageConverter()));
                    },
                    icon: Icon(Icons.image_outlined),
                    label: Text('Image to PDF'),
                  ),
                ],
              ),
            ],
          )
        ),
      )
    );
  }
  
    void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}