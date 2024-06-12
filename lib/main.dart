
import 'package:flutter/material.dart';
import 'package:harlem/mysql_flutter.dart';
import 'package:harlem/pdf_viewer_flutter.dart';
import 'package:harlem/qr_ftpscan.dart';
import 'package:harlem/qr_generator.dart';
import 'package:harlem/qr_scanner.dart';
import 'package:harlem/buttons.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:harlem/test.dart';
import 'package:harlem/wireless_printer.dart';

void main() {     
  usePathUrlStrategy();
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
  }
}