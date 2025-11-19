import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

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

  final Battery _battery = Battery();
  StreamSubscription? _netSub;

  @override
  void initState() {
    super.initState();
    _controller.loadRequest(Uri.parse(widget.url));

    _updateTime();
    _getBattery();
    _initNetwork();
  }

  void _updateTime() {
    setState(() => currentTime = DateFormat("HH:mm").format(DateTime.now()));
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
            child: Image.asset('assets/logo/app_icon.png',
                width: logoSize, height: logoSize),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: Image.asset('assets/logo/app_icon.png',
                width: logoSize, height: logoSize),
          )
        ],
      ),
    );
  }
}
