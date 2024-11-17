import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../urls.dart';
import 'error_page.dart';
import 'loading_widgets.dart';

class ModernWebViewPage extends StatefulWidget {
  const ModernWebViewPage({super.key});

  @override
  State<ModernWebViewPage> createState() => _ModernWebViewPageState();
}

class _ModernWebViewPageState extends State<ModernWebViewPage> {
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  late WebViewController _webViewController;
  bool _showFloatingControls = true;
  bool _canGoBack = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    // Set system UI overlay style for edge-to-edge design

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          if (url.contains('whatsapp')) {
            canLaunchUrl(Uri.parse(url)).then((canLaunch) {
              if (canLaunch) {
                launchUrl(Uri.parse(url));
              }
            });
          }
        
          setState(() {
            _isLoading = true;
            _loadingProgress = 0.0;
          });
          _checkCanGoBack();
        },
        onProgress: (int progress) {
          setState(() {
            _loadingProgress = progress / 100;
          });
        },
        onPageFinished: (String url) {
          setState(() {
            _isLoading = false;
          });
          _checkCanGoBack();
        },
        onNavigationRequest: (NavigationRequest request) {
          // Handle external links (email, phone, etc.)
          if (request.url.startsWith('tel:') ||
              request.url.startsWith('mailto:') ||
              request.url.startsWith('sms:')) {
            launchUrl(Uri.parse(request.url));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(
          'https://www.flourishsubscription.com.ng/mobile/login/')); // Replace with your URL

    // Enable pull to refresh
    _webViewController.enableZoom(true);
  }

  Future<void> _checkCanGoBack() async {
    final canGoBack = await _webViewController.canGoBack();
    if (mounted && canGoBack != _canGoBack) {
      setState(() {
        _canGoBack = canGoBack;
      });
    }
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    setState(() {
      _showFloatingControls = true;
    });
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFloatingControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Safe area for proper edge-to-edge display
          SafeArea(
            child: Stack(
              children: [
                // Main WebView
                WebViewWidget(controller: _webViewController),

                // Loading Progress Bar
                if (_isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _loadingProgress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ),

                // Loading Overlay
                if (_isLoading)
                  ModernLoadingOverlay(
                    isLoading: _isLoading,
                    primaryColor: Theme.of(context).primaryColor,
                    child: const SizedBox(),
                  ),
              ],
            ),
          ),

          // Floating Controls
          GestureDetector(
            onTapDown: (_) => _resetControlsTimer(),
            child: AnimatedOpacity(
              opacity: _showFloatingControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back Button
                        if (_canGoBack)
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded,
                                color: Colors.white),
                            onPressed: () async {
                              if (await _webViewController.canGoBack()) {
                                _webViewController.goBack();
                              }
                            },
                          ),

                        // Refresh Button
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white),
                          onPressed: () {
                            _webViewController.reload();
                            _resetControlsTimer();
                          },
                        ),

                        // Share Button
                        IconButton(
                          icon: const Icon(Icons.share_rounded,
                              color: Colors.white),
                          onPressed: () async {
                            final url = await _webViewController.currentUrl();
                            if (url != null) {
                              Share.share('Check this out: $url');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this utility function at the top of your file
Future<void> launchUrl(Uri url) async {
  if (await canLaunch(url.toString())) {
    await launch(url.toString());
  }
}
