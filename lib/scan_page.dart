import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:exam_spenda165/web_page.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  void _onDetect(BarcodeCapture barcode) {
    if (!_isScanned && barcode.barcodes.isNotEmpty) {
      final String scannedUrl = barcode.barcodes.first.rawValue ?? '';
      setState(() {
        _isScanned = true;
      });
      _controller.stop();

      // Navigasi ke WebPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebPage(url: scannedUrl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode'),
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}