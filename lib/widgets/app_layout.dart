import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Transparent overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Konten utama
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
