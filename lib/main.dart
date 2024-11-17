import 'package:flourish/app_lock.dart';
import 'package:flourish/landing.dart';
import 'package:flourish/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // check if user has opened app before
  WidgetsFlutterBinding.ensureInitialized();
  bool firstTime =
      (await SharedPreferences.getInstance()).getBool('opened') ?? false;
  runApp(
    MyApp(
      firstTime:true,
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.firstTime});
  bool firstTime;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flourish',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor:  Colors.blue,),
        useMaterial3: true,
      ),
      home: AppLock(
          lockScreenBuilder: (context) => const LockScreen(),
          backgroundLockLatency: Durations.extralong4,
          builder: (context, _) {
            // check if user has opened app before
            if (firstTime) {
              return const LandingPage();
            }
            return const ModernWebViewPage();
          }),
    );
  }
}
