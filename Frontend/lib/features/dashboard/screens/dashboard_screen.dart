// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../live_translation/screens/live_translation_screen.dart';
import '../../tutorial/screens/tutorial_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../settings/screens/settings_screen.dart';

// State provider to control active tab
final activeTabProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // List of screens corresponding to bottom navigation tabs
    final List<Widget> screens = [
      const DashboardHomeView(),
      const LiveTranslationScreen(),
      const TutorialScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSlate : AppTheme.lightBackground,
      body: screens[activeTab],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: activeTab,
          onTap: (index) => ref.read(activeTabProvider.notifier).state = index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
          selectedItemColor: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate_outlined),
              activeIcon: Icon(Icons.translate_rounded),
              label: 'Translate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school_rounded),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// Inner Home View of Dashboard summarizing statistics and activities
class DashboardHomeView extends ConsumerWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Welcome Header Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '@${authState.user?.username ?? "user"}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: isDark ? Colors.white : AppTheme.darkSlate,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.grey.shade200,
                child: Icon(
                  Icons.person_rounded,
                  color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Overview Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Quiz Score',
                  value: '${authState.user?.highScore ?? 0}',
                  subtitle: 'High score record',
                  icon: Icons.emoji_events_rounded,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Daily Streak',
                  value: '4 Days',
                  subtitle: 'Continuous learning',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Continue Learning Banner
          GestureDetector(
            onTap: () {
              // Directs to Tutorial screen (tab 2)
              ref.read(activeTabProvider.notifier).state = 2;
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isDark 
                      ? [AppTheme.neonPurple.withOpacity(0.8), AppTheme.neonCyan.withOpacity(0.8)]
                      : [AppTheme.lightAccent, const Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppTheme.neonPurple : AppTheme.lightAccent).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ]
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'RECOMMENDED',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Continue Emergency Signs',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Learn critical phrases like HOSPITAL and NEED WATER.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xBDFFFFFF), // transparent white
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 20,
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Quick Actions Grid Title
          Text(
            'Quick Action Console',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppTheme.darkSlate,
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              _buildActionCard(
                context,
                title: 'Real-time Camera',
                subtitle: 'Translate signs',
                icon: Icons.camera_front_rounded,
                color: AppTheme.neonCyan,
                onTap: () => ref.read(activeTabProvider.notifier).state = 1,
              ),
              _buildActionCard(
                context,
                title: 'ASL Directory',
                subtitle: 'Learn category vocabulary',
                icon: Icons.book_rounded,
                color: AppTheme.neonPurple,
                onTap: () => ref.read(activeTabProvider.notifier).state = 2,
              ),
              _buildActionCard(
                context,
                title: 'Archived Logs',
                subtitle: 'Review translations',
                icon: Icons.history_rounded,
                color: Colors.green,
                onTap: () => ref.read(activeTabProvider.notifier).state = 3,
              ),
              _buildActionCard(
                context,
                title: 'Synthesis Preferences',
                subtitle: 'Manage configurations',
                icon: Icons.settings_rounded,
                color: Colors.pinkAccent,
                onTap: () => ref.read(activeTabProvider.notifier).state = 4,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Daily Goals indicator card
          Card(
            color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Practice Target',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppTheme.darkSlate,
                        ),
                      ),
                      Text(
                        '60% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.6,
                      minHeight: 8,
                      backgroundColor: isDark ? AppTheme.darkSlate : Colors.grey.shade100,
                      color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Practice 3 more gestures from the Conversational set to unlock the Daily Challenger quiz bonus.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.trending_up_rounded, color: color, size: 14),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: isDark ? Colors.white : AppTheme.darkSlate,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 18,
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppTheme.darkSlate,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper color constant
extension TextStyleColor on TextStyle {
  static const Color ColorsWhiteBD = Color(0xBDFFFFFF);
}

const Color ColorsWhiteBD = Color(0xBDFFFFFF);
const Color ColorsWhite70 = Color(0xB2FFFFFF);
extension CustomColor on Colors {
  static const Color whiteBD = Color(0xBDFFFFFF);
}
