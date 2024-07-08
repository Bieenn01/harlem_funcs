
import 'package:flutter/material.dart';
import 'package:harlem/mysql_flutter.dart';
import 'package:harlem/pdf_viewer_flutter.dart';
import 'package:harlem/qr_ftpscan.dart';
import 'package:harlem/qr_generator.dart';
import 'package:harlem/qr_scanner.dart';
import 'package:harlem/buttons.dart';
import 'package:harlem/test.dart';
import 'package:harlem/wireless_printer.dart';

void main() {     
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/home',
      routes: {
        '/home' :(context) => const WidgetButton(),
        '/qrscanner-default' :(context) => WidgetQrScanner(),
        '/mysql-intergration' :(context) => MySqlFlutter(),
        '/qrscanner-mysql' :(context) => QrScannerFTP(),
        '/thermal-printer' :(context) => FlutterThermalPrinter(),
        '/qr-generator' :(context) => QRGenerator(),
        '/pdf-viewer' :(context) => PdfViewerFlutter(),
      },
      //home: PermissionHandlerWidget(),
    );
    // PS C:\Users\User\Documents\FlutterCode\harlem> flutter --version 
    // Flutter 3.19.6 • channel stable • https://github.com/flutter/flutter.git
    // Framework • revision 54e66469a9 (3 months ago) • 2024-04-17 13:08:03 -0700
    // Engine • revision c4cd48e186
    // Tools • Dart 3.3.4 • DevTools 2.31.1
    // PS C:\Users\User\Documents\FlutterCode\harlem> flutter downgrade 
  }
}