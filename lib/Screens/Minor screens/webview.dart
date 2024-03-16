// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfViewPage extends StatefulWidget {
  final String pdfUrl;

  const PdfViewPage({super.key, required this.pdfUrl});

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  String? _localFilePath;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    downloadPDFFile();
  }

  Future<void> downloadPDFFile() async {
    final url = widget.pdfUrl;
    final filename = url.substring(url.lastIndexOf('/') + 1);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    final response = await http.get(Uri.parse(url));

    await file.writeAsBytes(response.bodyBytes);

    if (mounted) {
      setState(() {
        _localFilePath = file.path;
      });
    }
  }

  void onPageChanged(int? page, int? total) {
    if (page != null && total != null) {
      setState(() {
        _currentPage = page;
        _totalPages = total;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: _localFilePath != null
          ? Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: _localFilePath!,
                    enableSwipe: true,
                    swipeHorizontal: true,
                    autoSpacing: true,
                    pageFling: true,
                    pageSnap: true,
                    defaultPage: 0,
                    fitPolicy: FitPolicy.BOTH,
                    onPageChanged: onPageChanged,
                    onViewCreated: (PDFViewController pdfViewController) {
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Page ${_currentPage + 1} of $_totalPages'),
                    ],
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
