import 'dart:async';
import 'dart:math';
import 'package:campus_connect/screens/auth/auth_wrapper.dart';
import 'package:campus_connect/screens/onboarding/onboarding_screen.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:campus_connect/utils/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Added for ImageFilter

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<double> _textFadeAnim;
  late Animation<double> _taglineFadeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _logoScaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _logoFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _textFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)),
    );
    _taglineFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.forward();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        CustomPageRoute(
          child: seenOnboarding ? const AuthWrapper() : const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a blue/purple gradient to match the logo
    final Color bgStart = const Color(0xFF283593); // Indigo 800
    final Color bgEnd = const Color(0xFF512DA8);   // Deep Purple 700
    final Color logoGlow = Color.lerp(bgStart, bgEnd, 0.5)!;
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            startColor: bgStart,
            endColor: bgEnd,
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft animated glow behind logo
                          Opacity(
                            opacity: 0.45 * _glowAnim.value,
                            child: Container(
                              width: 180 * _logoScaleAnim.value,
                              height: 180 * _logoScaleAnim.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    logoGlow.withOpacity(0.35),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Glassy/blurred circle for logo blending
                          ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.10),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: logoGlow.withOpacity(0.18),
                                      blurRadius: 32,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: ScaleTransition(
                                    scale: _logoScaleAnim,
                                    child: FadeTransition(
                                      opacity: _logoFadeAnim,
                                      child: ClipOval(
                                        child: AppStyles.logoWidget(width: 90, height: 90, fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  FadeTransition(
                    opacity: _textFadeAnim,
                    child: Text(
                      'Campus Connect',
                      style: AppStyles.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 16,
                            color: bgStart.withOpacity(0.25),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeTransition(
                    opacity: _taglineFadeAnim,
                    child: Text(
                      'Connecting Campus Life',
                      style: AppStyles.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.1,
                        shadows: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                            color: bgEnd.withOpacity(0.18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Use blue/purple themed floating shapes
          const AnimatedShapes(
            shapeColors: [
              Color(0xFF7986CB), // Indigo 300
              Color(0xFF9575CD), // Deep Purple 300
              Color(0xFFB39DDB), // Deep Purple 200
              Color(0xFF64B5F6), // Blue 300
            ],
          ),
          // Add creator credit at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: Text(
                'Developed By Abhinav',
                style: AppStyles.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.1,
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: Offset(0, 2),
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
}

class AnimatedBackground extends StatefulWidget {
  final Color startColor;
  final Color endColor;
  const AnimatedBackground({super.key, required this.startColor, required this.endColor});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(widget.startColor, widget.endColor, 0.5 + 0.5 * _controller.value)!,
                Color.lerp(widget.startColor, widget.endColor, 0.5 - 0.5 * _controller.value)!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedShapes extends StatefulWidget {
  final List<Color> shapeColors;
  const AnimatedShapes({super.key, this.shapeColors = const [
    Color(0xFF7986CB), // Indigo 300
    Color(0xFF9575CD), // Deep Purple 300
    Color(0xFFB39DDB), // Deep Purple 200
    Color(0xFF64B5F6), // Blue 300
  ]});

  @override
  State<AnimatedShapes> createState() => _AnimatedShapesState();
}

class _AnimatedShapesState extends State<AnimatedShapes> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final colors = widget.shapeColors;
          return Stack(
            children: [
              _floatingCircle(70, 0.13, 0.22, t, colors[0].withOpacity(0.13)),
              _floatingCircle(48, 0.68, 0.32, t + 0.2, colors[1].withOpacity(0.15)),
              _floatingCircle(36, 0.42, 0.78, t + 0.4, colors[2].withOpacity(0.13)),
              _floatingCircle(28, 0.82, 0.68, t + 0.6, colors[3].withOpacity(0.12)),
            ],
          );
        },
      ),
    );
  }

  Widget _floatingCircle(double size, double x, double y, double t, Color color) {
    final double dx = x + 0.03 * sin(2 * pi * t + size);
    final double dy = y + 0.03 * cos(2 * pi * t + size);
    return Positioned(
      left: MediaQuery.of(context).size.width * dx,
      top: MediaQuery.of(context).size.height * dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
} 