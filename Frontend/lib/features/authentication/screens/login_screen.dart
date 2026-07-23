// lib/features/authentication/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginTab = true;
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    final authNotifier = ref.read(authProvider.notifier);
    bool success = false;

    if (_isLoginTab) {
      success = await authNotifier.login(email, password);
      if (success && mounted) {
        // Successful login transitions to Dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } else {
      success = await authNotifier.register(email, password);
      if (success && mounted) {
        // Successful registration transitions to Profile Setup
        Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background glows
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.glowCyan,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
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

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Brand
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppTheme.darkSlateSecondary : Colors.grey.shade100,
                            border: Border.all(
                              color: AppTheme.neonCyan.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.fingerprint_rounded,
                            size: 48,
                            color: AppTheme.neonCyan,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _isLoginTab ? 'Console Login' : 'Secure Register',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: isDark ? Colors.white : AppTheme.darkSlate,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _isLoginTab
                              ? 'Authenticate with your user keys'
                              : 'Create an account to synchronize records',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tabs for Login / Register
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isLoginTab = true),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _isLoginTab ? AppTheme.neonCyan : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'SIGN IN',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: _isLoginTab ? AppTheme.neonCyan : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isLoginTab = false),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: !_isLoginTab ? AppTheme.neonCyan : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'REGISTER',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: !_isLoginTab ? AppTheme.neonCyan : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Error message alert
                      if (authState.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: Text(
                            authState.error!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'user@example.com',
                          prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                        ),
                        style: TextStyle(color: isDark ? Colors.white : AppTheme.darkSlate),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Field required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Security Key / Password',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        style: TextStyle(color: isDark ? Colors.white : AppTheme.darkSlate),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Password required';
                          if (!_isLoginTab) {
                            if (val.length < 8) return 'Password must be 8+ chars';
                            if (!RegExp(r'[A-Z]').hasMatch(val)) return 'Requires one uppercase letter';
                            if (!RegExp(r'[0-9]').hasMatch(val)) return 'Requires one number';
                            if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(val)) return 'Requires one symbol';
                          } else {
                            if (val.length < 6) return 'Password must be 6+ chars';
                          }
                          return null;
                        },
                      ),
                      if (!_isLoginTab) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_showConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                            ),
                          ),
                          style: TextStyle(color: isDark ? Colors.white : AppTheme.darkSlate),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please re-enter password';
                            if (val != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Submit Button
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonCyan,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.darkSlate,
                                ),
                              )
                            : Text(
                                _isLoginTab ? 'VERIFY SECURITY KEY' : 'REGISTER ENCRYPTED PROFILE',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
