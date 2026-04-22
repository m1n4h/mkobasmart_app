// lib/screens/authentication/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mkobasmart_app/screens/authentication/forgot_password.dart';
import 'package:mkobasmart_app/screens/authentication/guest_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mkobasmart_app/provider/auth_provider.dart';
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
  bool _obscurePassword = true;
  String? _loginError;

Future<void> _handleGoogleSignIn() async {
  try {
    // USE THE WEB CLIENT ID HERE
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: '340028363223-f2lsram6ridkilbcinb97atubuq9hoie.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );
    
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // This idToken is what you send to your Django/PostgreSQL backend
      final String? idToken = googleAuth.idToken; 
      debugPrint('ID Token for Django: $idToken');

      final authProvider = context.read<AuthProvider>();
      final ok = await authProvider.googleLogin(
        email: googleUser.email,
        name: googleUser.displayName ?? '',
      );
      
      if (mounted && ok) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else if (mounted && authProvider.error != null) {
        setState(() {
          _loginError = authProvider.error;
        });
      }
    }
  } catch (e) {
    debugPrint('Google Sign-In Error: $e');
    // ... rest of your error handling
  }
}
Future<void> _handleGuestLogin() async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const GuestInfoScreen()),
  );
}
  Future<void> _handleLogin() async {
    setState(() {
      _loginError = null;
    });

    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _loginError = 'Please enter both email/phone and password';
      });
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final isEmail = identifier.contains('@');
    final success = await authProvider.login(
      email: isEmail ? identifier : null,
      phone: isEmail ? null : identifier,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_admin', authProvider.currentUser?.isAdmin ?? false);
      await prefs.setBool('is_guest', authProvider.currentUser?.isGuest ?? false);
      await prefs.setString('user_email', authProvider.currentUser?.email ?? '');
      await prefs.setString('user_name', authProvider.currentUser?.fullName ?? '');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() {
        _loginError = authProvider.error ?? 'Invalid email or password';
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