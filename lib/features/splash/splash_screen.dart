import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
@override
void initState() {
  super.initState();
print("SPLASH INIT CALLED");
  _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 20));

  _scaleAnimation =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

  _fadeAnimation =
      CurvedAnimation(parent: _controller, curve: Curves.easeIn);

  _floatAnimation = Tween<double>(begin: -12, end: 12).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  _controller.repeat(reverse: true);

  // Safer delayed navigation
  Future.delayed(const Duration(seconds: 5), () {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  });
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _floatingShield({
    required double top,
    double? bottom,
    double? left,
    double? right,
    required double angle,
    required double size,
  }) {
    return Positioned(
      top: bottom == null ? top : null,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: child,
          );
        },
        child: Transform.rotate(
          angle: angle,
          child: Icon(
            Icons.shield_rounded,
            size: size,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // 🔹 Floating background shields (same positions, just animated)
          _floatingShield(
            top: -30,
            left: -20,
            angle: -0.2,
            size: 180,
          ),
          _floatingShield(
            top: 0,
            bottom: -50,
            right: -40,
            angle: 0.3,
            size: 200,
          ),
          _floatingShield(
            top: 150,
            right: -30,
            angle: -0.1,
            size: 100,
          ),

          // 🔹 Center content (UNCHANGED UI)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 200,
                    width: 200,
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: const [
                      Text(
                        "AEGIS",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Stay Safe. Stay Informed.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}