// lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/tts_service.dart';
import '../../authentication/providers/auth_provider.dart';

// State provider to control active speech speed (synthesis rate)
final speechSpeedProvider = StateProvider<double>((ref) => 0.5);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextToSpeechService _tts = TextToSpeechService();
  List<String> _voices = ['Default System Voice'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final list = await _tts.getAvailableVoices();
    if (mounted) {
      setState(() {
        _voices = list;
        _isLoading = false;
      });
    }
  }

  void _testSpeech(double rate) async {
    await _tts.setRate(rate);
    await _tts.speak('Vocalization testing channels at speed rate ${rate.toStringAsFixed(1)}');
  }

  void _logout() async {
    final isDark = ref.read(authProvider).user?.theme == 'dark';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
          title: Text(
            'Secure Log Out',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to end your session and clear local keys?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
                if (mounted) {
                  // Direct navigation back to Login screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
              child: const Text('LOG OUT', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentSpeed = ref.watch(speechSpeedProvider);
    final user = authState.user;
    final isDark = user?.theme == 'dark';

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.neonCyan),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSlate : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkSlate : Colors.white,
        elevation: 0,
        title: Text(
          'Preferences Panel',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.darkSlate,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Account Profile Card
          Card(
            color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isDark ? AppTheme.darkSlate : Colors.grey.shade100,
                    child: Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${user?.username ?? "user"}',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Themes Preference
          Card(
            color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
            child: ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
              ),
              title: Text(
                'Interface Theme',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                isDark ? 'Dark mode activated' : 'Light mode activated',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Switch(
                value: isDark,
                onChanged: (val) {
                  ref.read(authProvider.notifier).updateSettings(
                        theme: val ? 'dark' : 'light',
                      );
                },
                activeColor: AppTheme.neonCyan,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Voices Config Preference
          Card(
            color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Synthesis Channel',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _voices.contains(user?.preferredVoice) 
                        ? user?.preferredVoice 
                        : _voices.first,
                    dropdownColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.darkSlate),
                    items: _voices.map((v) {
                      return DropdownMenuItem<String>(
                        value: v,
                        child: Text(
                          v.split('/').last,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(authProvider.notifier).updateSettings(voice: val);
                        _tts.setPreferredVoice(val);
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: isDark ? AppTheme.darkSlate : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Speech Speed Panel Card
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
                      Row(
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Speech Speed Rate',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                      Text(
                        '${currentSpeed.toStringAsFixed(1)}x',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: currentSpeed,
                    min: 0.2,
                    max: 1.5,
                    divisions: 13,
                    activeColor: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                    onChanged: (val) {
                      ref.read(speechSpeedProvider.notifier).state = val;
                      _tts.setRate(val);
                    },
                    onChangeEnd: (val) {
                      _testSpeech(val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Logout Action
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('DISCONNECT CLIENT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.15),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.redAccent.withOpacity(0.3), width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
