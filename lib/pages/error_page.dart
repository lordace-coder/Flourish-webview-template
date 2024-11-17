import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key, required this.reload, required this.loadHome});

  final Future Function() reload;
  final Future Function() loadHome;

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  final Dio dio = Dio();
  bool isloading = false;
  String errorText = 'Your connection was interrupted';
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          Lottie.asset('assets/error_lottie.json'),
          const SizedBox(height: 20),
          Text(isloading ? 'Reconnecting...' : errorText),
          const SizedBox(height: 30),
          !isloading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isloading = true;
                    });
                    await widget.reload.call();
                    setState(() {
                      isloading = false;
                    });
                  },
                  child: const Text(
                    'Reload',
                    style: TextStyle(color: Colors.green),
                  )),
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isloading = true;
                    });
                    await widget.loadHome();
                    setState(() {
                      isloading = false;
                    });
                  },
                  child: const Text(
                    'Check Home',
                    style: TextStyle(color: Colors.green),
                  )),
            ],
          )
              : const CircularProgressIndicator(
            strokeAlign: CircularProgressIndicator.strokeAlignCenter,
            color: Colors.green,
          ),
          const Expanded(child: SizedBox(width: 20)),
          Image.asset(
            height: 50,
            width: 200,
            'assets/logo_txt.png',
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
