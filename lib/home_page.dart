import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

import 'scan_page.dart';
import 'network_helper.dart';
import 'widgets/app_layout.dart';
import 'widgets/custom_status_bar.dart';
import 'about_page.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentTime = "";
  int batteryLevel = 0;
  String networkStatus = "Offline";

  final Battery _battery = Battery();
  StreamSubscription? _netSub;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _getBattery();
    _initNetwork();
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat("HH:mm").format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  void _getBattery() async {
    batteryLevel = await _battery.batteryLevel;
    setState(() {});
  }

  void _initNetwork() async {
    networkStatus = await NetworkHelper.getNetworkStatus();
    setState(() {});

    _netSub = NetworkHelper.networkStream.listen((status) {
      setState(() => networkStatus = status);
    });
  }

  @override
  void dispose() {
    _netSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: CustomStatusBar(
                  batteryLevel: batteryLevel,
                  networkStatus: networkStatus,
                  currentTime: currentTime,
                ),
              ),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/logo/app_icon.png',
                          width: 250, height: 250),
                      SizedBox(height: 40),

                      ElevatedButton.icon(
                        icon: Icon(Icons.camera_alt, color: Color(0xFFF7B630)),
                        label: Text(
                          'SCAN BARCODE',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFF7B630),
                              fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFBB0000),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: networkStatus == "Online"
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ScanPage()),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.grey[800],
              onPressed: () => _promptExitKiosk(context),
              child: Icon(Icons.power_settings_new, color: Colors.white),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.info_outline, color: Colors.grey[700]),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => AboutPage()),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _promptExitKiosk(BuildContext context) async {
    String? password = await showDialog(
      context: context,
      builder: (context) => PasswordDialog(),
    );

    if (password == 'pasganjil2025/2026') {
      await stopKioskMode();
      Navigator.pop(context);
    }
  }
}

class PasswordDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController c = TextEditingController();

    return AlertDialog(
      title: Text('Masukkan Sandi'),
      content: TextField(
        controller: c,
        obscureText: true,
        decoration: InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(child: Text("Batal"), onPressed: () => Navigator.pop(context)),
        ElevatedButton(
          child: Text("OK"),
          onPressed: () => Navigator.pop(context, c.text),
        )
      ],
    );
  }
}
