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

  @override
  void initState() {
    super.initState();

    // Navigate to login after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });

    // Animation for logo and text
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // 🔹 Multiple translucent shield icons
          Positioned(
            top: -30,
            left: -20,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(Icons.shield_rounded, size: 180, color: Colors.white.withOpacity(0.1)),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -40,
            child: Transform.rotate(
              angle: 0.3,
              child: Icon(Icons.shield_rounded, size: 200, color: Colors.white.withOpacity(0.1)),
            ),
          ),
          Positioned(
            top: 150,
            right: -30,
            child: Transform.rotate(
              angle: -0.1,
              child: Icon(Icons.shield_rounded, size: 100, color: Colors.white.withOpacity(0.1)),
            ),
          ),

          // 🔹 Center content
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
