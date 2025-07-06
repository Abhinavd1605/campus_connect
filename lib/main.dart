import 'package:campus_connect/providers/theme_provider.dart';
import 'package:campus_connect/screens/splash_screen.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Campus Connect',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppStyles.primaryColor,
        scaffoldBackgroundColor: AppStyles.backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: AppStyles.primaryColor,
          secondary: AppStyles.accentColor,
          error: AppStyles.error,
          background: AppStyles.backgroundLight,
          surface: AppStyles.surfaceLight,
        ),
        textTheme: AppStyles.textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppStyles.backgroundLight,
          elevation: 0,
          titleTextStyle: AppStyles.textTheme.titleLarge?.copyWith(color: AppStyles.textDark),
          iconTheme: const IconThemeData(color: AppStyles.textDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: AppStyles.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingLarge, vertical: AppStyles.paddingMedium),
            textStyle: AppStyles.textTheme.labelLarge,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
          ),
          color: AppStyles.surfaceLight,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(vertical: AppStyles.paddingMedium, horizontal: AppStyles.paddingMedium),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.textMedium, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.textMedium, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.error, width: 2.0),
          ),
          labelStyle: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium),
          hintStyle: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium.withOpacity(0.7)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppStyles.primaryDark,
        scaffoldBackgroundColor: const Color(0xFF1A202C), // Dark background
        colorScheme: const ColorScheme.dark(
          primary: AppStyles.primaryColor,
          secondary: AppStyles.accentColor,
          error: AppStyles.error,
          background: Color(0xFF1A202C),
          surface: Color(0xFF2D3748),
        ),
        textTheme: AppStyles.textTheme.apply(bodyColor: AppStyles.textLight, displayColor: AppStyles.textLight),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1A202C),
          elevation: 0,
          titleTextStyle: AppStyles.textTheme.titleLarge?.copyWith(color: AppStyles.textLight),
          iconTheme: const IconThemeData(color: AppStyles.textLight),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: AppStyles.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingLarge, vertical: AppStyles.paddingMedium),
            textStyle: AppStyles.textTheme.labelLarge,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
          ),
          color: const Color(0xFF2D3748),
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(vertical: AppStyles.paddingMedium, horizontal: AppStyles.paddingMedium),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.textMedium, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.textMedium, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: const BorderSide(color: AppStyles.error, width: 2.0),
          ),
          labelStyle: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textLight),
          hintStyle: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textLight.withOpacity(0.7)),
        ),
      ),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
