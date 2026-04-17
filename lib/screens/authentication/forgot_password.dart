// lib/screens/authentication/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/glass_morphism.dart';
import '../../localization/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _identifierController = TextEditingController();
  bool _isEmail = true;
  String? _error;

  void _sendResetInstructions() {
    final identifier = _identifierController.text.trim();
    
    if (identifier.isEmpty) {
      setState(() {
        _error = 'Please enter your ${_isEmail ? 'email' : 'phone number'}';
      });
      return;
    }
    
    if (_isEmail && !identifier.contains('@')) {
      setState(() {
        _error = 'Please enter a valid email address';
      });
      return;
    }
    
    if (!_isEmail && identifier.length < 10) {
      setState(() {
        _error = 'Please enter a valid phone number';
      });
      return;
    }
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset instructions sent! Please check your inbox.')),
    );
    Navigator.pop(context);
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
                        Icons.lock_reset,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'forgot_password'.tr(context),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No worries. Enter your registered identifier and we\'ll send you instructions to reset your access.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      
                      // Toggle between email and phone
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(value: true, label: Text('Email')),
                          ButtonSegment<bool>(value: false, label: Text('Phone')),
                        ],
                        selected: {_isEmail},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _isEmail = newSelection.first;
                            _error = null;
                            _identifierController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      
                      TextField(
                        controller: _identifierController,
                        decoration: InputDecoration(
                          labelText: _isEmail ? 'email_or_phone'.tr(context) : 'phone_number'.tr(context),
                          prefixIcon: Icon(_isEmail ? Icons.email_outlined : Icons.phone_outlined),
                          hintText: _isEmail ? 'e.g. name@example.com' : '+255 712 345 678',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: _isEmail ? TextInputType.emailAddress : TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _sendResetInstructions,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text('reset_instructions'.tr(context)),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('remember_password'.tr(context)),
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