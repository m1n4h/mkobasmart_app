// lib/screens/authentication/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mkobasmart_app/screens/authentication/forgot_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/glass_morphism.dart';
import '../../localization/app_localizations.dart';
import '../dashboard/dashboard_screen.dart';
import 'create_account_screen.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  String? _loginError;

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', googleUser.email);
        await prefs.setString('user_name', googleUser.displayName ?? '');
        await prefs.setBool('is_logged_in', true);
        
        // Check if admin
        final isAdmin = googleUser.email.toLowerCase().contains('@mkobasmart.com');
        await prefs.setBool('is_admin', isAdmin);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', true);
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_admin', false);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loginError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _loginError = 'Please enter both email/phone and password';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    
    // For demo purposes, we'll check against stored credentials or accept test accounts
    final storedEmail = prefs.getString('user_email');
    final storedPassword = prefs.getString('user_password');
    
    // Test admin account
    if (email == 'admin@mkobasmart.com' && password == 'admin123') {
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', 'Admin User');
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_admin', true);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
      return;
    }
    
    // Check against stored credentials
    if (storedEmail == email && storedPassword == password) {
      await prefs.setBool('is_logged_in', true);
      final isAdmin = email.toLowerCase().contains('@mkobasmart.com');
      await prefs.setBool('is_admin', isAdmin);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      setState(() {
        _loginError = 'Invalid email or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [const Color(0xFF2E7D32), const Color(0xFF1E88E5)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedCard(
                delay: 0,
                child: GlassMorphism(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'MkobaSmart',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'EST 2024 • TAMAZNA',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'welcome_back'.tr(context),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PRECISION Digital Receipt Logged',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      if (_loginError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _loginError!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      if (_loginError != null) const SizedBox(height: 16),
                      
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'email_or_phone'.tr(context),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'password'.tr(context),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text('forgot_password'.tr(context)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text('sign_in'.tr(context)),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _handleGoogleSignIn,
                        icon: Image.asset(
                          'assets/images/google_logo.webp',
                          height: 24,
                          width: 24,
                        ),
                        label: Text('sign_in_google'.tr(context)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _handleGuestLogin,
                        child: Text('continue_as_guest'.tr(context)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('dont_have_account'.tr(context)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                              );
                            },
                            child: Text('create_account'.tr(context)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}