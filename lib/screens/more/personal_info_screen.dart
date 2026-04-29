import 'package:flutter/material.dart';
import 'package:mkobasmart_app/screens/authentication/auth_screen.dart';
import '../../localization/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/animated_card.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;

  const PersonalInfoScreen({
    super.key, 
    required this.currentName, 
    required this.currentEmail
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

 Future<void> _handleUpdate() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  // 1. Logic for Profile Update
  final profileResult = await AuthService().updateProfile(
    name: _nameController.text,
    email: _emailController.text,
  );

  // 2. Logic for Password Update
  bool passwordChanged = _passwordController.text.isNotEmpty;
  bool passwordSuccess = true;

  if (passwordChanged) {
    final passResult = await AuthService().changePassword(_passwordController.text);
    passwordSuccess = passResult['success'];
  }

  setState(() => _isSaving = false);

  if (profileResult['success'] && passwordSuccess) {
    if (passwordChanged) {
      // SUCCESS + PASSWORD CHANGED: Force Logout & Re-login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('your profile changed,Please login again to view our site.'))
      );
      
      await AuthService().logout(); // Clear tokens

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false, // Clears the entire stack
      );
    } else {
      // SUCCESS (Profile only): Just go back to More Screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated Successfully'))
      );
      Navigator.pop(context, true);
    }
  } else {
    // FAILURE
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Update failed. Check your connection or password rules.'), 
        backgroundColor: Colors.red
      )
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('personal_info'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 20),
              
              // Change Account Profile Section Header (mimicking your screenshot)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Change Account Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              AnimatedCard(
                delay: 100,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Column(
                    children: [
                      _buildTextField('Email', _emailController, Icons.email_outlined),
                      _buildTextField('Full Name', _nameController, Icons.person_outline),
                      _buildPasswordField('New Password', _passwordController),
                      _buildPasswordField('Repeat Password', _repeatPasswordController, isRepeat: true),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _handleUpdate,
                          icon: _isSaving 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save),
                          label: Text('save'.tr(context).toUpperCase()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, {bool isRepeat = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (value) {
              if (isRepeat && value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}