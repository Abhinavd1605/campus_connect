import 'package:campus_connect/screens/auth/auth_wrapper.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:campus_connect/utils/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onDone(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacement(
      CustomPageRoute(child: const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Lost Something? We've Got You Covered!",
          body: "Quickly report lost items and browse found items. Reconnect with your belongings effortlessly.",
          image: Column(
            children: [
              AppStyles.logoWithBackground(width: 70, height: 70),
              const SizedBox(height: AppStyles.marginMedium),
              const Icon(Icons.search, size: 60, color: AppStyles.primaryColor),
            ],
          ),
          decoration: const PageDecoration(
            pageColor: AppStyles.backgroundLight,
            titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: AppStyles.primaryColor),
            bodyTextStyle: TextStyle(fontSize: 16.0, color: AppStyles.textDark),
          ),
        ),
        PageViewModel(
          title: "Report Issues Anonymously",
          body: "Notice a problem on campus? Report maintenance, safety, or other issues anonymously and track their status.",
          image: Column(
            children: [
              AppStyles.logoWithBackground(width: 70, height: 70),
              const SizedBox(height: AppStyles.marginMedium),
              const Icon(Icons.report_problem, size: 60, color: AppStyles.accentColor),
            ],
          ),
          decoration: const PageDecoration(
            pageColor: AppStyles.backgroundLight,
            titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: AppStyles.primaryColor),
            bodyTextStyle: TextStyle(fontSize: 16.0, color: AppStyles.textDark),
          ),
        ),
        PageViewModel(
          title: "Your Campus, Connected",
          body: "Stay updated, manage your items, and help improve the campus, all from one place.",
          image: Column(
            children: [
              AppStyles.logoWithBackground(width: 70, height: 70),
              const SizedBox(height: AppStyles.marginMedium),
              const Icon(Icons.connect_without_contact, size: 60, color: AppStyles.primaryColor),
            ],
          ),
          decoration: const PageDecoration(
            pageColor: AppStyles.backgroundLight,
            titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: AppStyles.primaryColor),
            bodyTextStyle: TextStyle(fontSize: 16.0, color: AppStyles.textDark),
          ),
        ),
      ],
      onDone: () => _onDone(context),
      onSkip: () => _onDone(context),
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: AppStyles.primaryColor,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
} 