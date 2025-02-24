import 'package:flutter/material.dart';
import 'package:exam_spenda165/security_page.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await startKioskMode();
  runApp(ExamSpenda165App());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  WakelockPlus.enable();
}

class ExamSpenda165App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SecurityPage(),
    );
  }
}