import 'package:flutter/material.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:exam_spenda165/home_page.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  static const platform = MethodChannel('com.example.exam_spenda165/alarm');
  bool isKioskEnabled = false;
  bool isAppPinned = false;
  bool hasFloatingApp = false;
  bool isInternetConnected = false;
  int failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _watchKioskMode();
    _checkFloatingApps();
    _checkInternetConnection();
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

  Future<void> _checkFloatingApps() async {
    try {
      final bool isOverlayEnabled = await platform.invokeMethod('isOverlayEnabled');
      setState(() {
        hasFloatingApp = isOverlayEnabled;
      });
      if (isOverlayEnabled) {
        _triggerAlarm();
      }
    } on PlatformException catch (e) {
      print("Failed to check overlay: '\${e.message}'.");
    }
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      setState(() {
        isInternetConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      });
    } on SocketException catch (_) {
      setState(() {
        isInternetConnected = false;
      });
      _triggerAlarm();
    }
  }

  void _triggerAlarm() {
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false,
      volume: 100,
      asAlarm: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool securityPassed = isAppPinned && !hasFloatingApp && isInternetConnected;
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
              Text(isAppPinned ? 'Aplikasi sudah dipin' : 'Aplikasi belum dipin'),
              SizedBox(height: 10),
              Text(hasFloatingApp ? 'Terdeteksi aplikasi mengambang' : 'Tidak ada aplikasi mengambang'),
              SizedBox(height: 10),
              Text(isInternetConnected ? 'Internet aktif' : 'Internet tidak aktif'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: securityPassed
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage()),
                        );
                      }
                    : null,
                child: Text('Masuk ke Halaman Utama'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
