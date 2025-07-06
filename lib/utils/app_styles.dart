import 'package:flutter/material.dart';

class AppStyles {
  // --- Color Palette --- //
  // Primary & Accent Colors (Modern & Professional)
  static const Color primaryColor = Color(0xFF4A90E2); // A vibrant, professional blue
  static const Color primaryDark = Color(0xFF2E5BBA);  // A deeper shade for contrasts
  static const Color accentColor = Color(0xFFF5A623); // A bright, inviting orange/gold
  static const Color accentDark = Color(0xFFD08700);  // A deeper shade for accent

  // Neutral Colors (for text, backgrounds, and surfaces)
  static const Color backgroundLight = Color(0xFFF0F2F5); // Light grey for subtle backgrounds
  static const Color surfaceLight = Color(0xFFFFFFFF);     // Pure white for card surfaces
  static const Color textDark = Color(0xFF2C3E50);        // Dark charcoal for primary text
  static const Color textMedium = Color(0xFF7F8C8D);      // Medium grey for secondary text
  static const Color textLight = Color(0xFFECF0F1);       // Very light grey for text on dark backgrounds

  // Semantic Colors
  static const Color success = Color(0xFF2ECC71); // Green for success
  static const Color error = Color(0xFFE74C3C);   // Red for errors
  static const Color warning = Color(0xFFF39C12); // Orange for warnings

  // --- Gradients --- //
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Typography --- //
  static final TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: textDark),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: textDark),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textDark),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textDark),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textMedium),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textMedium),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textMedium),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textMedium),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textMedium),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: surfaceLight),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textMedium),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: textMedium),
  );

  // --- Spacing --- //
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  // --- Corner Radius --- //
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 15.0;
  static const double borderRadiusLarge = 20.0;

  // --- Box Shadows (for depth) --- //
  static List<BoxShadow> lightCardShadow = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      spreadRadius: 2,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // --- Glassmorphism --- //
  static BoxDecoration glassmorphismBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.15), // Adjusted opacity for subtle effect
      borderRadius: BorderRadius.circular(borderRadiusLarge),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 0.5, // Thinner border
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // Logo Widget (already defined)
  static Widget logoWidget({double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return ClipOval(
      child: Image.asset(
        'Logo/Logo.jpeg',
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }

  // Logo with background container (already defined)
  static Widget logoWithBackground({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    EdgeInsets padding = const EdgeInsets.all(16.0),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(borderRadiusLarge),
        boxShadow: lightCardShadow,
      ),
      child: logoWidget(
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }

  // Animated logo widget (already defined)
  static Widget animatedLogo({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: logoWidget(
              width: width,
              height: height,
              fit: fit,
            ),
          ),
        );
      },
    );
  }

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: Colors.white,
        surface: surfaceLight,
        onSurface: textDark,
        background: backgroundLight,
        onBackground: textDark,
        error: error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: surfaceLight,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Custom Widgets
  static Widget loadingWidget({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static Widget errorWidget({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: textTheme.bodyLarge?.copyWith(color: error),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
} 