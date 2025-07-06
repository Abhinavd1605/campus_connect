import 'package:campus_connect/models/lost_item.dart';
import 'package:campus_connect/screens/issues/report_issue_screen.dart';
import 'package:campus_connect/screens/lost_and_found/report_found_item_screen.dart';
import 'package:campus_connect/screens/lost_and_found/report_lost_item_screen.dart';
import 'package:campus_connect/services/database_service.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:campus_connect/utils/custom_page_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildGradientAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: AppStyles.marginLarge),
                  Text('Quick Actions', style: AppStyles.textTheme.headlineSmall),
                  const SizedBox(height: AppStyles.marginMedium),
                  _buildQuickActions(),
                  const SizedBox(height: AppStyles.marginLarge),
                  Text('Recent Lost Items', style: AppStyles.textTheme.headlineSmall),
                  const SizedBox(height: AppStyles.marginMedium),
                  _buildRecentLostItems(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientAppBar() {
    return SliverAppBar(
      expandedHeight: 170.0,
      backgroundColor: Colors.transparent,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: AppStyles.paddingLarge, bottom: AppStyles.paddingMedium),
        title: Row(
          children: [
            // Animated logo with glassy effect
            AnimatedLogoWidget(),
            const SizedBox(width: AppStyles.marginMedium),
            Expanded(child: _buildWelcomeMessage()),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppStyles.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppStyles.borderRadiusLarge),
              bottomRight: Radius.circular(AppStyles.borderRadiusLarge),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return FutureBuilder(
      future: _databaseService.getUserData(_user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Welcome!', style: AppStyles.textTheme.titleLarge);
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Welcome!', style: AppStyles.textTheme.titleLarge);
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text('Welcome, ${userData['name']}!',
            style: AppStyles.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
      },
    );
  }

  Widget _buildStatsGrid() {
    return FutureBuilder(
      future: Future.wait([
        _databaseService.getLostItemsCount(),
        _databaseService.getFoundItemsCount(),
        _databaseService.getMyReportedItemsCount(_user!.uid),
      ]),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Could not load stats.');
        }
        final stats = snapshot.data!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard('Lost Items', stats[0].toString(), Icons.search_off, AppStyles.primaryGradient),
            _buildStatCard('Found Items', stats[1].toString(), Icons.find_in_page, AppStyles.accentGradient),
            _buildStatCard('My Reports', stats[2].toString(), Icons.assignment_turned_in, AppStyles.accentGradient),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Gradient gradient) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppStyles.marginSmall),
        padding: const EdgeInsets.symmetric(vertical: AppStyles.paddingMedium),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: AppStyles.marginSmall),
            Text(count, style: AppStyles.textTheme.headlineMedium?.copyWith(color: Colors.white)),
            Text(title, style: AppStyles.textTheme.titleMedium?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionButton(
            icon: Icons.search_off,
            label: 'Lost',
            color: AppStyles.primaryColor,
            onPressed: () => Navigator.of(context).push(CustomPageRoute(
                child: const ReportLostItemScreen())),
          ),
          _buildQuickActionButton(
            icon: Icons.find_in_page,
            label: 'Found',
            color: AppStyles.accentColor,
            onPressed: () => Navigator.of(context).push(CustomPageRoute(
                child: const ReportFoundItemScreen())),
          ),
          _buildQuickActionButton(
            icon: Icons.report,
            label: 'Issue',
            color: AppStyles.error,
            onPressed: () => Navigator.of(context)
                .push(CustomPageRoute(child: const ReportIssueScreen())),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return Column(
      children: [
        Material(
          color: color,
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
            onTap: onPressed,
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: AppStyles.marginSmall),
        Text(label, style: AppStyles.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentLostItems() {
    return StreamBuilder<List<LostItem>>(
      stream: _databaseService.getLostItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error:  ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No recent items.');
        }
        final items = snapshot.data!.take(3).toList(); // Take first 3
        return Column(
          children: items.map((item) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: AppStyles.marginSmall),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
              ),
              color: AppStyles.surfaceLight,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.search_off, color: AppStyles.primaryColor),
                ),
                title: Text(item.itemName, style: AppStyles.textTheme.titleMedium),
                subtitle: Text('Lost at ${item.location}', style: AppStyles.textTheme.bodySmall),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// Animated logo widget for the app bar
class AnimatedLogoWidget extends StatefulWidget {
  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppStyles.primaryColor.withOpacity(0.13),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: ClipOval(
                child: AppStyles.logoWidget(width: 44, height: 44, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 