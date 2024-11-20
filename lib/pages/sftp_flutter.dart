import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dartssh2/dartssh2.dart';

class SFtpFlutter extends StatefulWidget {
  @override
  _SFtpFlutter createState() => _SFtpFlutter();
}

class _SFtpFlutter extends State<SFtpFlutter> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late SSHClient sshClient;
  late SftpClient sftpClient;

  bool _isConnected = false;
  List<String> fileList = [];

  @override
  void initState() {
    super.initState();
    connectSFTP();
  }

  Future<void> connectSFTP() async {
    try {
  

      final keyData = await rootBundle.load('lib/others/private_key.pem');
      final keyPem = utf8.decode(keyData.buffer.asUint8List());

      sshClient = SSHClient(
        await SSHSocket.connect('34.87.7.115', 22),
        username: 'rsa-key-20240823',
        // onPasswordRequest: () {
        //   stdout.write('Password: ');
        //   stdin.echoMode = false;
        //   return stdin.readLineSync() ?? exit(1);
        // },s
        identities: [
          ...SSHKeyPair.fromPem((keyPem))
        ]
        
      );

      sftpClient = await sshClient.sftp();
      final sftp = await sshClient.sftp();
      final items = await sftp.listdir('/');
      

      for (final item in items) {
        print(item.longname);
      }

      sshClient.close();
      await sshClient.done;
      
      print('Connection successful.');
      showToast('SFTP Log: Connected.');
      setState(() {
        _isConnected = true;
      });

      await listFiles();
    } catch (e) {
      print('Connection failed: $e');
      showToast('SFTP Log: Connection failed - $e');
    }
  }

  Future<void> listFiles() async {
    if (!_isConnected) {
      showToast('SFTP Log: Not connected.');
      return;
    }
    try {
      final directory = '/home/rsa-key-20240823/harlem_ftp';
      final files = await sftpClient.listdir(directory);
      setState(() {
        fileList = files.map((file) => file.longname).toList();
      });
      showToast('SFTP Log: Files listed successfully.');
    } catch (e) {
      showToast('SFTP Log: Error listing files - $e');
      print(e);
    }
  }

  Future<void> downloadAndPreviewPDF(String fileName) async {
    if (!_isConnected) {
      showToast('SFTP Log: Not connected.');
      return;
    }
    try {
      String remoteFilePath = '/home/rsa-key-20240823/harlem_ftp/$fileName';
      String localFilePath =
          (await getTemporaryDirectory()).path + '/$fileName';

      // Download the file
      // await sftpClient.download(remoteFilePath, localFilePath);

      final file = File(localFilePath);
      final Uint8List fileData = await file.readAsBytes();

      Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => SafeArea(
            child: PdfViewer(fileData: fileData),
          ),
        ),
      );
    } catch (e) {
      showToast('SFTP Log: Error - $e');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer Flutter'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
              semanticLabel: 'Refresh',
            ),
            onPressed: listFiles,
          ),
        ],
      ),
      body: _isConnected
          ? ListView.builder(
              itemCount: fileList.length,
              itemBuilder: (context, index) {
                final fileName = fileList[index];
                return ListTile(
                  title: Text(fileName),
                  onTap: () => downloadAndPreviewPDF(fileName),
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
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

class PdfViewer extends StatelessWidget {
  final Uint8List fileData;

  PdfViewer({required this.fileData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Preview'),
      ),
      body: SfPdfViewer.memory(fileData),
    );
  }
}
