// lib/features/authentication/screens/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/tts_service.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  List<String> _voices = ['Default System Voice'];
  String _selectedVoice = 'Default System Voice';
  String _selectedTheme = 'dark';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final list = await _ttsService.getAvailableVoices();
    if (mounted) {
      setState(() {
        _voices = list;
        if (list.isNotEmpty) {
          _selectedVoice = list.contains('en-us') 
              ? list.firstWhere((v) => v.toLowerCase().contains('en-us')) 
              : list.first;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final authNotifier = ref.read(authProvider.notifier);
    
    // Save updated voice settings & theme
    await authNotifier.updateSettings(
      voice: _selectedVoice,
      theme: _selectedTheme,
    );

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = _selectedTheme == 'dark';

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkSlate,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.neonCyan),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSlate : AppTheme.lightBackground,
      body: Stack(
        children: [
          // Ambient Glows for Dark theme
          if (isDark) ...[
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.glowPurple,
                ),
              ),
            ),
          ],

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Profile Console',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: isDark ? Colors.white : AppTheme.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize translation and visual synthesis parameters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Avatar Selector
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.grey.shade200,
                          child: Icon(
                            Icons.person_rounded,
                            size: 64,
                            color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.neonPurple : Colors.teal.shade700,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_camera_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'Welcome, @${authState.user?.username ?? "user"}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: isDark ? Colors.white : AppTheme.darkSlate,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Preferred Speech Voice Selection
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
                                size: 20,
                                color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Speech Synthesis Voice',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : AppTheme.darkSlate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select the synthesis engine preferred voice outputs',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedVoice,
                            dropdownColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
                            items: _voices.map((String v) {
                              return DropdownMenuItem<String>(
                                value: v,
                                child: Text(
                                  v.split('/').last,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white : AppTheme.darkSlate,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedVoice = val);
                                _ttsService.setPreferredVoice(val);
                                _ttsService.speak('Voice channel configured successfully');
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
                  const SizedBox(height: 16),

                  // Theme Selection
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
                                Icons.palette_rounded,
                                size: 20,
                                color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Visual Theme Preference',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : AppTheme.darkSlate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(child: Text('Futuristic Dark')),
                                  selected: _selectedTheme == 'dark',
                                  selectedColor: AppTheme.neonPurple.withOpacity(0.2),
                                  checkmarkColor: AppTheme.neonCyan,
                                  labelStyle: TextStyle(
                                    color: _selectedTheme == 'dark' 
                                        ? AppTheme.neonCyan 
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedTheme = 'dark');
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(child: Text('Teal Light')),
                                  selected: _selectedTheme == 'light',
                                  selectedColor: AppTheme.lightAccent.withOpacity(0.2),
                                  checkmarkColor: AppTheme.lightAccent,
                                  labelStyle: TextStyle(
                                    color: _selectedTheme == 'light' 
                                        ? AppTheme.lightAccent 
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedTheme = 'light');
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Complete Profile Button
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                      foregroundColor: isDark ? AppTheme.darkSlate : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'INITIALIZE INTERFACE',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
