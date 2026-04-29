import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../services/auth_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  const PersonalInfoScreen({super.key, required this.currentName, required this.currentEmail});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    final result = await AuthService().updateProfile(
      name: _nameController.text,
      email: _emailController.text,
    );

    setState(() => _isSaving = false);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated')));
      Navigator.pop(context, true); // Return true to refresh MoreScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('personal_info'.tr(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manage Account', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              _buildField('Email', _emailController, Icons.email),
              _buildField('Full Name', _nameController, Icons.person),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleUpdate,
                  icon: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
                  label: Text('save'.tr(context)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Center(child: Text('Cancel', style: TextStyle(color: Colors.red))),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}