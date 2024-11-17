import 'dart:ui';

import 'package:flutter/material.dart';

class ModernLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Color? backgroundColor;
  final Color? primaryColor;

  const ModernLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.backgroundColor,
    this.primaryColor,
  }) : super(key: key);

  @override
  State<ModernLoadingOverlay> createState() => _ModernLoadingOverlayState();
}

class _ModernLoadingOverlayState extends State<ModernLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ModernLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: (widget.backgroundColor ?? Colors.black).withOpacity(0.3),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Center(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: CustomLoadingSpinner(
                                  color: widget.primaryColor ?? Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ShimmeringText(
                                text: 'Loading...',
                                baseColor: widget.primaryColor ?? Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class CustomLoadingSpinner extends StatefulWidget {
  final Color color;

  const CustomLoadingSpinner({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  State<CustomLoadingSpinner> createState() => _CustomLoadingSpinnerState();
}

class _CustomLoadingSpinnerState extends State<CustomLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SpinnerPainter(
            color: widget.color,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class SpinnerPainter extends CustomPainter {
  final Color color;
  final double progress;

  SpinnerPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    // Draw background circle
    paint.color = color.withOpacity(0.2);
    canvas.drawCircle(center, radius, paint);

    // Draw animated arc
    paint.color = color;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      progress * 2 * 3.14159,
      3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(SpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class ShimmeringText extends StatefulWidget {
  final String text;
  final Color baseColor;

  const ShimmeringText({
    Key? key,
    required this.text,
    required this.baseColor,
  }) : super(key: key);

  @override
  State<ShimmeringText> createState() => _ShimmeringTextState();
}

class _ShimmeringTextState extends State<ShimmeringText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  widget.baseColor.withOpacity(0.5),
                  widget.baseColor,
                  widget.baseColor.withOpacity(0.5),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(
                Rect.fromLTWH(
                  -100 * _controller.value,
                  0,
                  200,
                  0,
                ),
              ),
          ),
        );
      },
    );
  }
}