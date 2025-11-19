import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'widgets/custom_status_bar.dart';
import 'home_page.dart';
import 'network_helper.dart';

class WebPage extends StatefulWidget {
  final String url;
  const WebPage({required this.url, Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  final WebViewController _controller =
      WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);

  String currentTime = "";
  int batteryLevel = 0;
  String networkStatus = "Offline";

  bool menuOpen = false;

  final Battery _battery = Battery();
  StreamSubscription? _netSub;
  Timer? _batteryTimer;

  @override
  void initState() {
    super.initState();
    _controller.loadRequest(Uri.parse(widget.url));

    _updateTime();
    _startBatteryWatcher();
    _initNetwork();

    _checkViolation(); // Tidak mengeluarkan apa-apa
  }

  // UPDATE JAM
  void _updateTime() {
    setState(() => currentTime = DateFormat("HH:mm").format(DateTime.now()));
    Future.delayed(const Duration(seconds: 1), _updateTime);
  }

  // PANTAU BATERAI
  void _startBatteryWatcher() {
    _batteryTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      batteryLevel = await _battery.batteryLevel;
      setState(() {});
      // Tidak melakukan apa-apa meskipun low battery
    });
  }

  // NETWORK
  void _initNetwork() async {
    networkStatus = await NetworkHelper.getNetworkStatus();
    setState(() {});

    _netSub = NetworkHelper.networkStream.listen((status) {
      setState(() => networkStatus = status);
    });
  }

  // CEK PELANGGARAN (tidak bunyi apapun)
  void _checkViolation() {
    // Kosong sesuai permintaan (tidak alarm, tidak toast)
  }

  // EXIT APP DENGAN PASSWORD
  Future<void> _exitApp() async {
    final controller = TextEditingController();

    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Masukkan Password"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Password"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    if (result == "pasganjil2025/2026") {
      SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    _batteryTimer?.cancel();
    _netSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double logoSize = MediaQuery.of(context).size.width * 0.12;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _controller)),

          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: CustomStatusBar(
              batteryLevel: batteryLevel,
              networkStatus: networkStatus,
              currentTime: currentTime,
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: Image.asset(
              'assets/logo/app_icon.png',
              width: logoSize,
              height: logoSize,
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: Image.asset(
              'assets/logo/app_icon.png',
              width: logoSize,
              height: logoSize,
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (menuOpen) ...[
            FloatingActionButton(
              heroTag: "refresh",
              mini: true,
              onPressed: () => _controller.reload(),
              child: const Icon(Icons.refresh),
            ),
            const SizedBox(height: 10),

            FloatingActionButton(
              heroTag: "back",
              mini: true,
              onPressed: () async {
                if (await _controller.canGoBack()) _controller.goBack();
              },
              child: const Icon(Icons.arrow_back),
            ),
            const SizedBox(height: 10),

            FloatingActionButton(
              heroTag: "forward",
              mini: true,
              onPressed: () async {
                if (await _controller.canGoForward()) _controller.goForward();
              },
              child: const Icon(Icons.arrow_forward),
            ),
            const SizedBox(height: 10),

            FloatingActionButton(
              heroTag: "exit",
              mini: true,
              backgroundColor: Colors.red,
              onPressed: _exitApp,
              child: const Icon(Icons.power_settings_new),
            ),
            const SizedBox(height: 10),
          ],

          FloatingActionButton(
            heroTag: "menu",
            onPressed: () => setState(() => menuOpen = !menuOpen),
            child: Icon(menuOpen ? Icons.close : Icons.menu),
          ),
        ],
      ),
    );
  }
}
