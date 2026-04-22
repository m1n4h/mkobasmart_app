// lib/screens/authentication/otp_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mkobasmart_app/provider/otp_provider.dart';
import 'package:mkobasmart_app/services/otp_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/glass_morphism.dart';
import '../dashboard/dashboard_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String identifier;
  final bool isEmail;

  const OTPVerificationScreen({
    super.key,
    required this.identifier,
    required this.isEmail,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;
  String _error = '';
  bool _isLoading = false;
  int _resendCooldown = 30;
  Timer? _resendTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (index) => TextEditingController());
    _focusNodes = List.generate(6, (index) => FocusNode());
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCooldown = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;
    
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    final otpProvider = context.read<OTPProvider>();
    final sent = await otpProvider.sendOTP(
      identifier: widget.identifier,
      isEmail: widget.isEmail,
    );
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      if (!sent) {
        setState(() {
          _error = otpProvider.error ?? 'Failed to resend code';
        });
        return;
      }

      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
      _startResendTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code sent to ${widget.identifier}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      setState(() {
        _error = 'Please enter the 6-digit verification code';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    final otpService = OTPService();
    final verifyResult = await otpService.verifyOTP(
      identifier: widget.identifier,
      otp: otp,
      isEmail: widget.isEmail,
    );

    if (verifyResult['success']) {
      await otpService.persistVerificationSession(verifyResult['data']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', true);
      await prefs.setBool('is_admin', false);
      await prefs.setString('guest_identifier', widget.identifier);
      await prefs.setString('guest_type', widget.isEmail ? 'email' : 'phone');
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _error = verifyResult['error']?.toString() ?? 'Invalid verification code. Please try again.';
      });
    }
  }

  void _onOTPChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify when all fields are filled
    final allFilled = _otpControllers.every((c) => c.text.length == 1);
    if (allFilled) {
      _verifyOTP();
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
                        Icons.verified_user,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Verify Your Identity',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit code sent to',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        _maskIdentifier(widget.identifier),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 50,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                              ),
                              onChanged: (value) => _onOTPChanged(index, value),
                            ),
                          );
                        }),
                      ),
                      
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _error,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Verify Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOTP,
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
                            : Text('Verify & Continue'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Resend OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          GestureDetector(
                            onTap: _canResend && !_isLoading ? _resendOTP : null,
                            child: Text(
                              _canResend ? 'Resend' : 'Resend in ${_resendCooldown}s',
                              style: TextStyle(
                                color: _canResend && !_isLoading
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Change identifier
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Use different ${widget.isEmail ? "email" : "phone number"}'),
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

  String _maskIdentifier(String identifier) {
    if (widget.isEmail) {
      final parts = identifier.split('@');
      if (parts[0].length > 2) {
        return '${parts[0][0]}***${parts[0][parts[0].length - 1]}@${parts[1]}';
      }
      return identifier;
    } else {
      if (identifier.length > 6) {
        return '***${identifier.substring(identifier.length - 4)}';
      }
      return identifier;
    }
  }
}