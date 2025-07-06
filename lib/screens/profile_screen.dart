import 'package:campus_connect/models/found_item.dart';
import 'package:campus_connect/models/issue.dart';
import 'package:campus_connect/models/lost_item.dart';
import 'package:campus_connect/providers/theme_provider.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:campus_connect/services/database_service.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final User? _user = FirebaseAuth.instance.currentUser;
  late AnimationController _animController;
  late Animation<double> _picAnim;
  late Animation<double> _nameAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _picAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _nameAnim = CurvedAnimation(parent: _animController, curve: const Interval(0.3, 1.0, curve: Curves.easeIn));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: _user == null
          ? const Center(child: Text('Not logged in.'))
          : FutureBuilder(
              future: _databaseService.getUserData(_user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Could not load profile.'));
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                return CustomScrollView(
                  slivers: [
                    _buildProfileAppBar(userData),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        _buildProfileDetailsCard(userData),
                        _buildSettingsCard(),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ],
                );
              },
            ),
    );
  }

  SliverAppBar _buildProfileAppBar(Map<String, dynamic> userData) {
    final String? profileUrl = (userData['profilePictureUrl'] as String?)?.isNotEmpty == true ? userData['profilePictureUrl'] : null;
    return SliverAppBar(
      expandedHeight: 260.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async => await _authService.signOut(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF283593), Color(0xFF512DA8)],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white.withOpacity(0.15)],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  ScaleTransition(
                    scale: _picAnim,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                            child: profileUrl == null
                                ? const Icon(Icons.person, size: 54, color: Colors.white70)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeTransition(
                    opacity: _nameAnim,
                    child: Text(
                      userData['name'] ?? 'No Name',
                      style: AppStyles.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FadeTransition(
                    opacity: _nameAnim,
                    child: Text(
                      userData['email'] ?? '',
                      style: AppStyles.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailsCard(Map<String, dynamic> userData) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildProfileDetailRow(Icons.email, 'Email', userData['email'] ?? 'Not Provided'),
                  _buildProfileDetailRow(Icons.school, 'College', userData['college'] ?? 'Not Provided'),
                  _buildProfileDetailRow(Icons.work, 'Department', userData['department'] ?? 'Not Provided'),
                  _buildProfileDetailRow(Icons.calendar_today, 'Year', (userData['year'] ?? 'N/A').toString()),
                  _buildProfileDetailRow(Icons.phone, 'Phone', userData['phone'] ?? 'Not Provided'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E6F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF283593), size: 22),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Flexible(
            child: Text(value ?? '', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            );
          },
        ),
      ),
    );
  }
} 