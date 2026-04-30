// lib/screens/authentication/create_account_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mkobasmart_app/provider/auth_provider.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/glass_morphism.dart';
import '../../localization/app_localizations.dart';
import '../dashboard/dashboard_screen.dart';
import 'auth_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }


void _validateAndCreateAccount() async {
    setState(() {
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;
    final email = _emailController.text.trim().toLowerCase();

    // 1. Basic Full Name Check
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    // 2. Email Validation & Admin Domain Check
    if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      isValid = false;
    } 
    
    // 3. Phone Validation
    if (!_isValidPhone(_phoneController.text.trim())) {
      setState(() => _phoneError = 'Please enter a valid phone number (e.g., +255712345678)');
      isValid = false;
    }

    // 4. Password Validation
    if (!_isValidPassword(_passwordController.text)) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    }

    // 5. Terms Agreement
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms and conditions')),
      );
      return;
    }

    if (isValid) {
      final fullName = _fullNameController.text.trim();
      final names = fullName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
      final username = email.split('@').first;

      final authProvider = context.read<AuthProvider>();
      
      // The provider will handle the actual API call
      final registered = await authProvider.register(
        username: username,
        email: email,
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        firstName: firstName,
        lastName: lastName,
      );

      if (registered && mounted) {
        // Distinct success message based on domain
        bool isAdmin = email.endsWith('@mkobasmart.com');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAdmin 
              ? 'Admin account created! Please sign in to access the Command Panel.' 
              : 'Account created successfully! Please sign in.'),
            backgroundColor: isAdmin ? Colors.blue : Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
        
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Failed to create account')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
   return Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
  ),
  extendBodyBehindAppBar: true, // optional for gradient effect
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
                        Icons.person_add,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'create_account'.tr(context),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join MkobaSmart today',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Full Name
                      TextField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'email_or_phone'.tr(context),
                          prefixIcon: const Icon(Icons.email_outlined),
                          errorText: _emailError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'phone_number'.tr(context),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          errorText: _phoneError,
                          hintText: '+255 712 345 678',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'password'.tr(context),
                          prefixIcon: const Icon(Icons.lock_outline),
                          errorText: _passwordError,
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
                      const SizedBox(height: 16),
                      
                      // Confirm Password
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          errorText: _confirmPasswordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Terms and Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeTerms = value ?? false;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeTerms = !_agreeTerms;
                                });
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: 'I agree to the ',
                                  style: TextStyle(color: Colors.grey[600]),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Create Account Button
                      ElevatedButton(
                        onPressed: _validateAndCreateAccount,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text('create_account'.tr(context)),
                      ),
                      const SizedBox(height: 16),
                      
                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('already_have_account'.tr(context)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const AuthScreen()),
                              );
                            },
                            child: Text('sign_in'.tr(context)),
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