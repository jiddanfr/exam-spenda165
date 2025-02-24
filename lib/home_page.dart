import 'package:flutter/material.dart';
import 'package:exam_spenda165/scan_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Spenda165'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Halaman Ujian Siap Digunakan'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanPage(),
                  ),
                );
              },
              child: Text('Scan Barcode'),
            ),
          ],
        ),
      ),
    );
  }
}
