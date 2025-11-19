import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Aplikasi'),
        backgroundColor: Color(0xFFBB0000),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spenda Exam',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBB0000),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Aplikasi ini dikembangkan khusus oleh pengembang aplikasi SMP Negeri 2 Pandaan sebagai sarana pelaksanaan ujian berbasis digital. '
              'Dilengkapi dengan pin mode dan pengamanan untuk memastikan integritas ujian tetap terjaga.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Fitur utama:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            BulletPoint(text: 'Pemindaian barcode untuk akses soal.'),
            BulletPoint(text: 'Mode kiosk untuk mengunci aplikasi.'),
            BulletPoint(text: 'Status bar khusus menampilkan baterai & jaringan.'),
            BulletPoint(text: 'Tampilan minimalis dan mudah digunakan.'),
            SizedBox(height: 30),
            Spacer(),
            Center(
              child: Text(
                '© 2025 SMP Negeri 2 Pandaan\nSeluruh hak cipta dilindungi. ~JFR',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('• ', style: TextStyle(fontSize: 16)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
      ],
    );
  }
}
