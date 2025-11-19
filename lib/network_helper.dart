// network_helper.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class NetworkHelper {
  // ------------------------------
  //  S T R E A M   R E A L T I M E
  // ------------------------------
  static final StreamController<String> _networkController =
      StreamController<String>.broadcast();

  static Stream<String> get networkStream => _networkController.stream;

  static bool _isInitialized = false;

  // Panggil sekali di main.dart
  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    Connectivity().onConnectivityChanged.listen((result) async {
      String status =
          await _checkInternetConnection() ? "Online" : "Offline";

      _networkController.add(status);
    });

    // Cek awal
    _checkInternetConnection().then((online) {
      _networkController.add(online ? "Online" : "Offline");
    });
  }

  // ---------------------------------
  //  F U T U R E  CHECK – sekali panggil
  // ---------------------------------
  static Future<String> getNetworkStatus() async {
    bool online = await _checkInternetConnection();
    return online ? "Online" : "Offline";
  }

  // ---------------------------------
  //  Cek internet dengan DNS ping
  // ---------------------------------
  static Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup("google.com")
          .timeout(const Duration(seconds: 2));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
