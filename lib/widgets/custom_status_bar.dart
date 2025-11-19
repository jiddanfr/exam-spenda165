import 'package:flutter/material.dart';

class CustomStatusBar extends StatelessWidget {
  final int batteryLevel;
  final String networkStatus;
  final String currentTime;
  final double fontSize;

  const CustomStatusBar({
    Key? key,
    required this.batteryLevel,
    required this.networkStatus,
    required this.currentTime,
    this.fontSize = 14.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("🔋 $batteryLevel%", 
            style: TextStyle(color: Colors.white, fontSize: fontSize)),
          
          Text("📶 $networkStatus", 
            style: TextStyle(color: Colors.white, fontSize: fontSize)),
          
          Text("🕒 $currentTime", 
            style: TextStyle(color: Colors.white, fontSize: fontSize)),
        ],
      ),
    );
  }
}
