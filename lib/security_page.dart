import 'package:flutter/material.dart';
import 'package:exam_spenda165/home_page.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';

import 'widgets/app_layout.dart';
import 'widgets/custom_status_bar.dart';

class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  static const platform = MethodChannel('com.example.exam_spenda165/alarm');

  final Battery _battery = Battery();

  bool hasFloatingApp = false;
  bool isInternetConnected = false;

  int batteryLevel = 0;

  String networkStatus = "Tidak ada jaringan";
  String currentTime = "";

  @override
  void initState() {
    super.initState();
    _initializeSecurityChecks();
  }

  /// ------------------------------------------------------------
  ///  ALL INITIAL SECURITY CHECKS
  /// ------------------------------------------------------------
  void _initializeSecurityChecks() {
    _checkFloatingApps();
    _checkInternetConnection();
    _updateBattery();
    _updateNetworkStatus();
    _tickClock();
  }

  /// ------------------------------------------------------------
  ///  CHECK FLOATING APPS (OVERLAY)
  /// ------------------------------------------------------------
  Future<void> _checkFloatingApps() async {
    try {
      final bool isOverlayEnabled =
          await platform.invokeMethod('isOverlayEnabled');

      setState(() {
        hasFloatingApp = isOverlayEnabled;
      });
    } catch (e) {
      print("Overlay check error: $e");
    }
  }

  /// ------------------------------------------------------------
  ///  INTERNET CHECK
  /// ------------------------------------------------------------
  Future<void> _checkInternetConnection() async {
    try {
      final lookup = await InternetAddress.lookup('google.com');
      final connected = lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;

      setState(() {
        isInternetConnected = connected;
        networkStatus = connected ? "Terhubung" : "Tidak ada jaringan";
      });
    } catch (_) {
      setState(() {
        isInternetConnected = false;
        networkStatus = "Tidak ada jaringan";
      });
    }
  }

  /// ------------------------------------------------------------
  ///  BATTERY
  /// ------------------------------------------------------------
  Future<void> _updateBattery() async {
    final level = await _battery.batteryLevel;
    setState(() => batteryLevel = level);
  }

  /// ------------------------------------------------------------
  ///  NETWORK TYPE (WiFi / Mobile)
  /// ------------------------------------------------------------
  Future<void> _updateNetworkStatus() async {
    final result = await Connectivity().checkConnectivity();

    setState(() {
      if (result.contains(ConnectivityResult.mobile)) {
        networkStatus = "Data Seluler";
      } else if (result.contains(ConnectivityResult.wifi)) {
        networkStatus = "WiFi";
      } else {
        networkStatus = "Tidak ada jaringan";
      }
    });
  }

  /// ------------------------------------------------------------
  /// CLOCK UPDATE
  /// ------------------------------------------------------------
  void _tickClock() {
    setState(() {
      currentTime = DateFormat('HH:mm').format(DateTime.now());
    });

    Future.delayed(const Duration(seconds: 1), _tickClock);
  }

  /// ------------------------------------------------------------
  ///  GO TO HOME + ACTIVATE KIOSK MODE
  /// ------------------------------------------------------------
  Future<void> _goToHomePage() async {
    await platform.invokeMethod('startKioskMode');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  /// ------------------------------------------------------------
  ///  UI
  /// ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: CustomStatusBar(
              batteryLevel: batteryLevel,
              networkStatus: networkStatus,
              currentTime: currentTime,
            ),
          ),

          /// IMAGE
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/peraturan.png',
                width: 700,
                height: 700,
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// FOOTER + BUTTON
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBB0000),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  onPressed: (hasFloatingApp || !isInternetConnected)
                      ? null
                      : _goToHomePage,
                  child: const Text(
                    "START  ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFF7B630),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '© 2025 SMP Negeri 2 Pandaan Seluruh hak cipta dilindungi. ~JFR',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
