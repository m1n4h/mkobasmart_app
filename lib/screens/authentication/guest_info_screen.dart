// lib/screens/authentication/guest_info_screen.dart
import 'package:flutter/material.dart';
import 'package:mkobasmart_app/provider/auth_provider.dart';
import 'package:mkobasmart_app/provider/otp_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/glass_morphism.dart';

import 'otp_verification_screen.dart';

class GuestInfoScreen extends StatefulWidget {
  const GuestInfoScreen({super.key});

  @override
  State<GuestInfoScreen> createState() => _GuestInfoScreenState();
}

class _GuestInfoScreenState extends State<GuestInfoScreen> {
  final TextEditingController _identifierController = TextEditingController();
  bool _isEmail = true;
  bool _isLoading = false;
  String? _error;

  Future<void> _sendOTP() async {
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
    
    if (!_isEmail && !RegExp(r'^\+255\d{9}$').hasMatch(identifier)) {
      setState(() {
        _error = 'Please enter phone in +255XXXXXXXXX format';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    final otpProvider = context.read<OTPProvider>();
    final sent = await otpProvider.sendOTP(
      identifier: identifier,
      isEmail: _isEmail,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (!sent) {
        setState(() {
          _error = otpProvider.error ?? 'Failed to send OTP';
        });
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            identifier: identifier,
            isEmail: _isEmail,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Provider.of<AuthProvider>(context);
    
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
                        Icons.person_outline,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your email or phone number to receive a verification code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Toggle between Email and Phone
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEmail = true;
                                    _error = null;
                                    _identifierController.clear();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isEmail ? Theme.of(context).primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Email',
                                      style: TextStyle(
                                        color: _isEmail ? Colors.white : Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEmail = false;
                                    _error = null;
                                    _identifierController.clear();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isEmail ? Theme.of(context).primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Phone Number',
                                      style: TextStyle(
                                        color: !_isEmail ? Colors.white : Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Input Field
                      TextField(
                        controller: _identifierController,
                        decoration: InputDecoration(
                          labelText: _isEmail ? 'Email Address' : 'Phone Number',
                          prefixIcon: Icon(_isEmail ? Icons.email_outlined : Icons.phone_outlined),
                          hintText: _isEmail ? 'example@email.com' : '0712345678',
                          errorText: _error,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: _isEmail ? TextInputType.emailAddress : TextInputType.phone,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // // Info Text
                      // Container(
                      //   padding: const EdgeInsets.all(12),
                      //   decoration: BoxDecoration(
                      //     color: Colors.blue.withOpacity(0.1),
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.info_outline, size: 20, color: Colors.blue),
                      //       const SizedBox(width: 12),
                      //       Expanded(
                      //         child: Text(
                      //           'We\'ll send a verification code to your ${_isEmail ? "email" : "phone number"}. You can use the app as a guest with limited features.',
                      //           style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      
                      const SizedBox(height: 24),
                      
                      // Send OTP Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text('Send '),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Back to Login
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Back to Login'),
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