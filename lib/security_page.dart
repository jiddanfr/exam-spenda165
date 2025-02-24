import 'package:flutter/material.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:exam_spenda165/home_page.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool isKioskEnabled = false;
  bool isAppPinned = false;
  int failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _watchKioskMode();
  }

  void _watchKioskMode() {
    watchKioskMode().listen((mode) async {
      setState(() {
        isKioskEnabled = mode == KioskMode.enabled;
        isAppPinned = isKioskEnabled;
      });

      if (!isKioskEnabled) {
        _triggerAlarm();
        await startKioskMode();
      }
    });
  }

  void _triggerAlarm() {
   FlutterRingtonePlayer().play(
  android: AndroidSounds.notification,
  ios: IosSounds.glass,
  looping: false, // Android only - API >= 28
  volume: 100, // Android only - API >= 28
  asAlarm: false, // Android only - all APIs
);
  }

  void _promptExitKiosk() async {
    String? password = await showDialog(
      context: context,
      builder: (context) => PasswordDialog(),
    );

    if (password == 'spenda165admin') {
      await stopKioskMode();
      setState(() {
        isKioskEnabled = false;
        isAppPinned = false;
      });
      Navigator.pop(context);
    } else {
      failedAttempts++;
      if (failedAttempts >= 3) {
        _triggerAlarm();
        await Future.delayed(Duration(minutes: 1));
        failedAttempts = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _triggerAlarm();
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isAppPinned ? 'Aplikasi sudah terpin' : 'Aplikasi belum terpin'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isAppPinned
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage()),
                        );
                      }
                    : null,
                child: Text('Masuk ke Halaman Ujian'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _promptExitKiosk,
                child: Text('Keluar dari Mode Kiosk'),
              ),
            ],
          ),
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