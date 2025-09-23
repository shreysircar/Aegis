import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // 🔹 Background shield
          Positioned(
            bottom: -50,
            left: -40,
            child: Icon(
              Icons.shield_rounded,
              size: 200,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // 🔹 Additional translucent shield icon
          Positioned(
            top: 100,
            right: -30,
            child: Transform.rotate(
              angle: 0.15,
              child: Icon(
                Icons.shield_rounded,
                size: 120,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Logo
                    Image.asset(
                      "assets/images/logo.png",
                      height: 90,
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "Stay Safe. Stay Informed.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Name field
                              TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  hintText: "Full Name",
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),

                              // Email field
                              TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  hintText: "Email",
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.email, color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  hintText: "Password",
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),

// Confirm Password field
                              TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  hintText: "Confirm Password",
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              // 🔹 Sign Up Button inside SignupScreen
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  // Navigate to Home screen
                                  Navigator.pushReplacementNamed(context, '/home');
                                },
                                child: const Text("Sign Up"),
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.white30)),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text("OR", style: TextStyle(color: Colors.white70)),
                                  ),
                                  Expanded(child: Divider(color: Colors.white30)),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _socialButton(Icons.g_mobiledata, "Google"),
                                  const SizedBox(width: 12),
                                  _socialButton(Icons.code_outlined, "GitHub"),
                                ],
                              ),
                              const SizedBox(height: 20),

                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text(
                                  "Already have an account? Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(IconData icon, String label) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
