import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FTPServerWidget extends StatefulWidget {
  @override
  _FTPServerWidgetState createState() => _FTPServerWidgetState();
}

class _FTPServerWidgetState extends State<FTPServerWidget> {
  late FTPServer _ftpServer;

  @override
  void initState() {
    super.initState();
    _ftpServer = FTPServer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
          title: Text('FTP Integration'),
        ),
        body: Container(
          color: Colors.black,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.all(25),
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 2, color: Color.fromARGB(255, 161, 139, 139)),
                borderRadius: BorderRadius.circular(25),
                color: const Color.fromARGB(255, 223, 189, 189),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _ftpServer.connectFTP,
                      child: Text('Connect to FTP Server'),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    ElevatedButton(
                      onPressed: () => _ftpServer.pickFile(context),
                      child: Text('Pick File'),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    ElevatedButton(
                      onPressed: () => _ftpServer.takePicture(context),
                      child: Text('Take Picture'),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    ElevatedButton(
                      onPressed: _ftpServer.uploadFilePicked,
                      child: Text('Upload to FTP'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FTPServer extends ChangeNotifier {
  FTPConnect? ftpConnect;
  FilePickerResult? result;
  File? _imageFile;

  Future<void> connectFTP() async {
    ftpConnect = FTPConnect(
      '10.0.0.11',
      user: 'root',
      pass: 'alpha',
      securityType: SecurityType.FTP,
      showLog: true,
    );
    showToast('FTP Log: Connection initiated.');
    notifyListeners();
    print('FTP Log: Connection initiated.');
  }

  Future<void> pickFile(BuildContext context) async {
    result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result!.paths.isNotEmpty) {
      notifyListeners();
    } else {
      print("No files selected");
    }
  }

  Future<void> takePicture(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      bool connected = await ftpConnect!.connect();
      await ftpConnect?.changeDirectory('test');
      if (!connected) {
        throw 'Failed to connect to FTP server';
      }

      await ftpConnect!.uploadFile(File(pickedImage.path));
      ftpConnect?.listDirectoryContent();
      showToast('FTP Log: Image uploaded successfully.');
    
      if (result != null) {
        for (String? pickedImage in result!.paths.where((path) => path != null)) {
          await ftpConnect!.uploadFile(File(pickedImage!));
          ftpConnect?.listDirectoryContent();
        }
        showToast('FTP Log: Files uploaded successfully.');
      }
    } else {
      showToast('No image selected.');
    }
  }

  Future<void> uploadFilePicked() async {
    try {
      if (ftpConnect == null) {
        throw 'FTP connection not established';
      }
      if ((result == null || result!.paths.isEmpty) && _imageFile == null) {
        throw 'No files selected';
      }

      bool connected = await ftpConnect!.connect();
      await ftpConnect?.changeDirectory('test/pdf');
      if (!connected) {
        throw 'Failed to connect to FTP server';
      }

      if (_imageFile != null) {
        await ftpConnect!.uploadFile(File(_imageFile!.path));
        ftpConnect?.listDirectoryContent();
        showToast('FTP Log: Image uploaded successfully.');
      }

      if (result != null) {
        for (String? filePath in result!.paths.where((path) => path != null)) {
          await ftpConnect!.uploadFile(File(filePath!));
          ftpConnect?.listDirectoryContent();
        }
        showToast('FTP Log: Files uploaded successfully.');
      }
    } catch (e) {
      showToast('FTP Log: Error: $e');
      print('FTP Log: Error: $e');
    }
    notifyListeners();
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
