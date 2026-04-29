// lib/screens/more/change_password_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../authentication/auth_screen.dart'; // Make sure this path is correct

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passController = TextEditingController();
  final _repeatPassController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  Future<void> _updatePassword() async {
    // 1. Validation
    if (_passController.text.isEmpty) {
      _showSnackBar('Please enter a new password');
      return;
    }
    if (_passController.text != _repeatPassController.text) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    // 2. Call Service
    final result = await AuthService().changePassword(_passController.text);

    setState(() => _isLoading = false);

    if (result['success']) {
      if (!mounted) return;

      _showSnackBar('Password changed! Please login again with your new password.');

      // 3. Force Logout & Redirect
      await AuthService().logout(); // Clears tokens/prefs

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false, // Clears the entire navigation stack
      );
    } else {
      _showSnackBar('Failed to update password. Check your connection.');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPassField('New Password', _passController),
            const SizedBox(height: 16),
            _buildPassField('Repeat Password', _repeatPassController),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: hint,
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}