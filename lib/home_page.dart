import 'package:flutter/material.dart';
import 'package:exam_spenda165/scan_page.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class HomePage extends StatelessWidget {
  void _promptExitKiosk(BuildContext context) async {
    String? password = await showDialog(
      context: context,
      builder: (context) => PasswordDialog(),
    );

    if (password == 'spenda165admin') {
      await stopKioskMode();
      Navigator.pop(context);
    }
  }

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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _promptExitKiosk(context),
              child: Text('Keluar Aplikasi'),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController _passwordController = TextEditingController();
    return AlertDialog(
      title: Text('Masukkan Sandi'),
      content: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(hintText: 'Sandi'),
      ),
      actions: [
        TextButton(
          child: Text('Batal'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.pop(context, _passwordController.text),
        ),
      ],
    );
  }
}
