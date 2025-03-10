//security_page.dart
import 'package:flutter/material.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:exam_spenda165/home_page.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';


class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  static const platform = MethodChannel('com.example.exam_spenda165/alarm');
  bool hasFloatingApp = false;
  bool isInternetConnected = false;
  int batteryLevel = 0;
  String networkStatus = "Tidak ada jaringan";
  String currentTime = "";
  final Battery _battery = Battery();
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _checkFloatingApps();
    _checkInternetConnection();
    _getBatteryLevel();
    _getNetworkStatus();
    _updateTime();
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
      print("Failed to check overlay: '${e.message}'.");
    }
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      setState(() {
        isInternetConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        networkStatus = isInternetConnected ? "Terhubung" : "Tidak ada jaringan";
      });
    } on SocketException catch (_) {
      setState(() {
        isInternetConnected = false;
        networkStatus = "Tidak ada jaringan";
      });
      _triggerAlarm();
    }
  }

  Future<void> _getBatteryLevel() async {
    final level = await _battery.batteryLevel;
    setState(() {
      batteryLevel = level;
    });
  }

  void _getNetworkStatus() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    setState(() {
      if (results.contains(ConnectivityResult.mobile)) {
        networkStatus = "Data Seluler";
      } else if (results.contains(ConnectivityResult.wifi)) {
        networkStatus = "WiFi";
      } else {
        networkStatus = "Tidak ada jaringan";
      }
    });
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat('HH:mm').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  void _triggerAlarm() {
    FlutterRingtonePlayer().play(fromAsset: "assets/sounds/alarm.mp3");
  }

  void _goToHomePage() async {
    await platform.invokeMethod('startKioskMode');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

 void _showSettings() {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Menghindari ukuran berlebih
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pengaturan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListTile(
                  dense: true, // Membuat lebih ringkas
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  leading: Icon(Icons.brightness_6),
                  title: Text("Mode Gelap"),
                  trailing: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) => Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (val) {
                        themeProvider.toggleTheme();
                        setModalState(() {});
                      },
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  leading: Icon(Icons.format_size),
                  title: Text("Ubah Ukuran Font"),
                  trailing: SizedBox(
                    width: 120, // Batasi ukuran slider
                    child: Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 24.0,
                      onChanged: (val) {
                        setModalState(() {
                          _fontSize = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Halaman Keamanan"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Baterai: $batteryLevel%"),
            Text("Jaringan: $networkStatus"),
            Text("Waktu: $currentTime"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (hasFloatingApp || !isInternetConnected) ? null : _goToHomePage,
              child: Text("Home"),
            ),
          ],
        ),
      ),
    );
  }
}
