// web_page.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class WebPage extends StatefulWidget {
  final String url;

  WebPage({required this.url});

  @override
  _WebPageState createState() => _WebPageState();
}
class PasswordDialog extends StatefulWidget {
  @override
  _PasswordDialogState createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Masukkan Password'),
      content: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(labelText: 'Password'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_passwordController.text);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class _WebPageState extends State<WebPage> {
  late WebViewController _controller;
  bool _isMenuOpen = false;
  bool _isStatusVisible = false;
  static const platform = MethodChannel('com.example.exam_spenda165/alarm');
  static const kioskPlatform = MethodChannel('com.example.exam_spenda165/kiosk');
  final Battery _battery = Battery();
  String _batteryLevel = 'Unknown';
  String _connectionStatus = 'Unknown';
  String _currentTime = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkViolations();
    _updateStatus();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateStatus();
      _checkLowBattery();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    final batteryLevel = await _battery.batteryLevel;
    var connectivityResult = await (Connectivity().checkConnectivity());
    String formattedTime = DateFormat('HH:mm').format(DateTime.now());

    setState(() {
      _batteryLevel = '$batteryLevel%';
      _connectionStatus = connectivityResult == ConnectivityResult.mobile
          ? 'Data Seluler'
          : connectivityResult == ConnectivityResult.wifi
              ? 'Wi-Fi'
              : 'Tidak Terhubung';
      _currentTime = formattedTime;
    });
  }

  void _checkLowBattery() {
    int battery = int.tryParse(_batteryLevel.replaceAll('%', '')) ?? 100;
    if (battery <= 20) {
      _triggerLowBatteryAlarm();
    }
  }

  void _triggerLowBatteryAlarm() {
    FlutterRingtonePlayer().play(
      android: AndroidSounds.alarm,
      ios: IosSounds.glass,
      looping: false,
      volume: 1.0,
      asAlarm: true,
    );
  }

  void _triggerAlarm() {
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false,
      volume: 1.0,
      asAlarm: false,
    );
  }

  Future<void> _checkViolations() async {
    try {
      final bool isOverlayEnabled = await platform.invokeMethod('isOverlayEnabled');
      final bool isInternetConnected = await platform.invokeMethod('isInternetConnected');

      if (!isOverlayEnabled || !isInternetConnected) {
        _triggerAlarm();
      }
    } on PlatformException catch (e) {
      print("Failed to check violations: '\${e.message}'.");
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _toggleStatusVisibility() {
    setState(() {
      _isStatusVisible = !_isStatusVisible;
    });
  }

  void _refreshPage() {
    _controller.reload();
  }

  void _goBack() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    }
  }

  void _goForward() async {
    if (await _controller.canGoForward()) {
      _controller.goForward();
    }
  }

  Future<void> _showPasswordDialog() async {
    final password = await showDialog<String>(
      context: context,
      builder: (context) => PasswordDialog(),
    );

    if (password == 'spenda165admin') {
      await stopKioskMode();
      SystemNavigator.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password salah!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ujian'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isStatusVisible)
            Positioned(
              top: 10,
              right: 10,
              child: Card(
                elevation: 4,
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Baterai: $_batteryLevel'),
                      Text('Koneksi: $_connectionStatus'),
                      Text('Jam: $_currentTime'),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isMenuOpen) ...[
            FloatingActionButton(
              heroTag: 'settings',
              onPressed: () {},
              child: Icon(Icons.settings),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'status',
              onPressed: _toggleStatusVisibility,
              child: Icon(Icons.info_outline),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'refresh',
              onPressed: _refreshPage,
              child: Icon(Icons.refresh),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'back',
              onPressed: _goBack,
              child: Icon(Icons.arrow_back),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'forward',
              onPressed: _goForward,
              child: Icon(Icons.arrow_forward),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'exit',
              onPressed: _showPasswordDialog,
              backgroundColor: Colors.red,
              child: Icon(Icons.power_settings_new),
            ),
          ],
          FloatingActionButton(
            heroTag: 'menu',
            onPressed: _toggleMenu,
            child: Icon(_isMenuOpen ? Icons.close : Icons.menu),
          ),
        ],
      ),
    );
  }
}
