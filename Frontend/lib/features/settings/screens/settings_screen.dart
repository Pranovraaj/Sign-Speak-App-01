// lib/features/settings/screens/settings_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../authentication/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _faceIdEnabled = true;
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() { _isUploadingImage = true; });
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        await ref.read(authProvider.notifier).updateProfileDetails(
          profilePictureBase64: 'data:image/jpeg;base64,$base64String'
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isUploadingImage = false; });
      }
    }
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
          content: const Text('Are you sure you want to end your session?'),
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

  void _showLanguageDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
          title: Text('Select Language', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['English', 'Spanish', 'French', 'German', 'Hindi'].map((lang) {
              return ListTile(
                title: Text(lang),
                onTap: () {
                  // Save language logic here later
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language set to $lang')));
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showSupportDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
          title: Text('Support', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: const Text('If you need help or have any questions, please contact us at:\n\nsupport@signspeak.com\n+1 (800) 123-4567'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
          title: Text('Terms & Privacy', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: const SingleChildScrollView(
            child: Text('1. Introduction\nWelcome to SignSpeak. By using our app, you agree to these terms.\n\n2. Privacy\nWe respect your privacy. Your data is encrypted and secure.\n\n3. Usage\nPlease use the app responsibly.'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('AGREE & CLOSE'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountDialog(bool isDark, String currentUsername, String currentEmail) {
    final usernameCtrl = TextEditingController(text: currentUsername);
    final emailCtrl = TextEditingController(text: currentEmail);
    final passwordCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
              title: Text('Account Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email Address'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      decoration: const InputDecoration(labelText: 'New Password (Optional)'),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() => isLoading = true);
                          try {
                            await ref.read(authProvider.notifier).updateProfileDetails(
                              username: usernameCtrl.text.trim(),
                              newEmail: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                              newPassword: passwordCtrl.text.trim().isNotEmpty ? passwordCtrl.text.trim() : null,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account updated!')));
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                            setDialogState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = user?.theme == 'dark';

    final Color bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA);
    final Color cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () {
            // Can go back to dashboard tab if we implement tab controller back logic, or just ignore since it's a bottom nav tab.
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          // Profile Header
          Row(
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  backgroundImage: user?.profilePictureBase64 != null
                      ? MemoryImage(
                          const Base64Decoder().convert(user!.profilePictureBase64!.split(',').last),
                        )
                      : null,
                  child: _isUploadingImage
                      ? const CircularProgressIndicator()
                      : user?.profilePictureBase64 == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 32,
                              color: isDark ? Colors.white : Colors.grey.shade600,
                            )
                          : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? "Dianne Russell",
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(
                      user?.email ?? 'dianne.russell@mail.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _pickAndUploadImage,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Edit profile', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ),
          
          const SizedBox(height: 32),

          // Preferences Section
          Text(
            'Preferences',
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: subtitleColor),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications and sounds',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.grey.shade400,
                  ),
                  textColor: textColor,
                  iconColor: subtitleColor,
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.translate_rounded,
                  title: 'Language',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('English', style: TextStyle(color: subtitleColor, fontSize: 13)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 18),
                    ],
                  ),
                  textColor: textColor,
                  iconColor: subtitleColor,
                  onTap: () => _showLanguageDialog(isDark),
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.brightness_4_rounded,
                  title: 'Theme',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isDark ? 'Dark' : 'Light', style: TextStyle(color: subtitleColor, fontSize: 13)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 18),
                    ],
                  ),
                  textColor: textColor,
                  iconColor: subtitleColor,
                  onTap: () {
                    ref.read(authProvider.notifier).updateSettings(theme: isDark ? 'light' : 'dark');
                  }
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          // Account Section
          Text(
            'Account',
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: subtitleColor),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Account',
                  trailing: Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 18),
                  textColor: textColor,
                  iconColor: subtitleColor,
                  onTap: () => _showAccountDialog(isDark, user?.username ?? '', user?.email ?? ''),
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Support',
                  trailing: Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 18),
                  textColor: textColor,
                  iconColor: subtitleColor,
                  onTap: () => _showSupportDialog(isDark),
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Terms and Privacy Policy',
                  trailing: Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 18),
                  textColor: textColor,
                  iconColor: subtitleColor,
                  onTap: () => _showTermsDialog(isDark),
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: _logout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required Color textColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minLeadingWidth: 20,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
    );
  }
}
