// lib/screens/more/more_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/animated_card.dart';
import '../../localization/app_localizations.dart';
import '../authentication/auth_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Section
          AnimatedCard(
            delay: 0,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'John Mwalimu',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'mwalimu@mkobasmart.com',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {},
                  child: Text('edit_profile'.tr(context)),
                ),
              ],
            ),
          ),
          
          // Settings Options
          AnimatedCard(
            delay: 100,
            child: Column(
              children: [
                _buildSettingsTile(
                  context: context, 
                  icon: Icons.person_outline,
                  title: 'personal_info'.tr(context),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context: context, 
                  icon: Icons.lock_outline,
                  title: 'change_password'.tr(context),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context: context, 
                  icon: Icons.notifications_outlined,
                  title: 'notifications'.tr(context),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context: context, 
                  icon: Icons.language,
                  title: 'language'.tr(context),
                  onTap: () {
                    // Show language selector
                  },
                ),
                _buildSettingsTile(
                  context: context, 
                  icon: Icons.dark_mode_outlined,
                  title: 'theme'.tr(context),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context: context, 
                  icon: Icons.file_download_outlined,
                  title: 'data_export'.tr(context),
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          // Support Section
          AnimatedCard(
            delay: 200,
            child: Column(
              children: [
                _buildSettingsTile(
                  context: context, 
                  icon: Icons.help_outline,
                  title: 'help_support'.tr(context),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context: context, 
                  icon: Icons.privacy_tip_outlined,
                  title: 'privacy_policy'.tr(context),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context: context, 
                  icon: Icons.description_outlined,
                  title: 'terms_conditions'.tr(context),
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          // Logout Button
          AnimatedCard(
            delay: 300,
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: Text('logout'.tr(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

 Widget _buildSettingsTile({
  required BuildContext context, // ✅ ADD THIS
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: Theme.of(context).primaryColor),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
}