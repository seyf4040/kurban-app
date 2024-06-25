import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


import 'package:kurban_app/src/models/group.dart';


class GeneratePdf {

  String? _logo;

  GeneratePdf();

  void showPrintAllDialog(BuildContext context, List<Group> groups){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Print Group Details'),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: PdfPreview(
              initialPageFormat: PdfPageFormat.a4.landscape,
              build: (format) async {
                print("ici?");
                var pdf = pw.Document();
                try {
                  _logo = await rootBundle.loadString('images/phpl_logo.svg');
                } catch (e) {
                  _logo = '';
                  print("ici?");
                  if (kDebugMode) {
                    print("ici?");
                    print("Error loading logo: $e");
                    
                  }
                }
                for (var group in groups) {
                  pdf = await _generatePdf(format, pdf, group);
                }
                return pdf.save();
                },
              allowPrinting: true,
              allowSharing: true,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showPrintDialog(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Print Group Details'),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: PdfPreview(
              initialPageFormat: PdfPageFormat.a4.landscape,
              build: (format) async {
                var pdf = pw.Document();
                try {
                  _logo = await rootBundle.loadString('images/phpl_logo.svg');
                } catch (e) {
                  _logo = '';
                  if (kDebugMode) {
                    print("Error loading logo: $e");
                  }
                }
                pdf = await _generatePdf(format, pdf, group);
                return pdf.save();
                },
              allowPrinting: true,
              allowSharing: true,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<pw.Document> _generatePdf(PdfPageFormat format, pw.Document pdf, Group group) async {
    try {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: format,
            orientation: pw.PageOrientation.landscape,
            margin: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
          
          header: (context) => _buildHeader(context, group),
          build: (context) => [
              pw.SizedBox(height: 10),
              _contentTable(context, group),
            ],
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error creating pdf: $e");
      }
    }
    return pdf;
  }

  pw.Widget _contentTable(pw.Context context, Group group){
    return pw.ListView.builder(
      itemCount: group.members.length,
      itemBuilder: (context, index) {
        final member = group.members[index];
        return pw.Container(
          alignment: pw.Alignment.centerLeft,
          // margin: pw.EdgeInsets.symmetric(vertical: 8),
          // padding: pw.EdgeInsets.all(12),
          // decoration: pw.BoxDecoration(
          //   border: pw.Border.all(color: PdfColors.black),
          //   borderRadius: pw.BorderRadius.circular(8),
          // ),
          child: pw.Text(
            '${index+1}. ${member.name} ${member.surname}',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: 40,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green,
            ),
          ),
        );
      },
    );
  }

  pw.Widget _buildHeader(pw.Context context, Group group) {
     return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 70,
                    padding: const pw.EdgeInsets.only(left: 20),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      group.groupName,
                      style: pw.TextStyle(
                        color: PdfColors.green100,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 60,
                      ),
                    ),
                  ),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      borderRadius:
                          pw.BorderRadius.all(pw.Radius.circular(2)),
                      color: PdfColors.green900,
                    ),
                    padding: const pw.EdgeInsets.only(
                        left: 40, top: 10, bottom: 10, right: 20),
                    alignment: pw.Alignment.centerLeft,
                    height: 50,
                    child: pw.DefaultTextStyle(
                      style: const pw.TextStyle(
                        color: PdfColors.green100,
                        fontSize: 12,
                      ),
                      child: pw.GridView(
                        crossAxisCount: 2,
                        children: [
                          pw.Text('Ülke:'),
                          pw.Text("Bengladesh"),
                          pw.Text('Tarih:'),
                          pw.Text(_formatDate(DateTime.now())),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                alignment: pw.Alignment.topRight,
                // padding: const pw.EdgeInsets.only(bottom: 8, left: 30),
                height: 150,
                child:
                    _logo != null ? pw.SvgImage(svg: _logo!, colorFilter: PdfColors.green900) : pw.PdfLogo(),
              ),
            ),
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  String _formatDate(DateTime date) {
    final format = DateFormat.yMEd();
    return format.format(date);
  }
}