import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello World')),
        body: PdfPreview(
          build: (format) => _generatePdf(format),
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(
      version: PdfVersion.pdf_1_5,
      compress: true,
    );

    final fontData = await rootBundle.load("assets/fonts/timr45w.ttf");
    final font = pw.Font.ttf(fontData.buffer.asByteData());

    const int count = 60;
    const PdfPageFormat format = PdfPageFormat(8.5 * PdfPageFormat.inch, 
    11 * PdfPageFormat.inch, marginAll: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          final List<pw.Widget> children = [];
          children.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _buildHeaderCell('Column 1', font),
                _buildHeaderCell(' Column 2', font),
                _buildHeaderCell(' Column 3', font),
                _buildHeaderCell(' Column 4', font),
                _buildHeaderCell(' Column 5', font),
                _buildHeaderCell(' Column 6', font),
              ],
            ),
          );
          for (int index = 1; index < count; index++) {
            children.add(
              pw.Row(
                children: [
                  _buildCell(_generateText(index), font),
                  _buildCell(_generateText(index), font),
                  _buildCell(_generateText(index), font),
                  _buildCell(_generateText(index), font),
                  _buildCell(_generateText(index), font),
                  _buildCell(_generateText(index), font),
                ],
              ),
            );
          }
          return pw.Column(children: children);
        },
      ),
    );
    return pdf.save();
  }

  pw.Widget _buildCell(String text, pw.Font font) {
    return pw.Expanded(
      child: pw.FittedBox(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildHeaderCell(String text, pw.Font font) {
    return pw.Expanded(
      child: pw.FittedBox(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            font: font,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _generateText(int index) {
    return ' $index.) Hello World';
  }
}
