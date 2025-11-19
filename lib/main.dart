import 'package:flutter/material.dart';
import 'package:exam_spenda165/security_page.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'network_helper.dart'; // TAMBAHKAN

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi pengecekan internet real-time
  NetworkHelper.initialize();

  runApp(ExamSpenda165App());

  // Fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Prevent screen from sleeping
  WakelockPlus.enable();
}

class ExamSpenda165App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.getTheme(),
            home: SecurityPage(),
          );
        },
      ),
    );
  }
}
