// lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:mkobasmart_app/screens/authentication/auth_screen.dart';
import 'package:provider/provider.dart';
import '../../provider/admin_provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/glass_morphism.dart';
import '../../localization/app_localizations.dart';
import 'user_management_screen.dart';
import 'system_logs_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final adminProv = Provider.of<AdminProvider>(context);
    final user = authProv.currentUser;

    // Trigger data fetch if empty
    if (adminProv.stats.isEmpty && !adminProv.isLoading) {
      Future.microtask(() => adminProv.fetchAdminData());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('admin_panel')),
      ),
      drawer: _buildAdminDrawer(context, authProv),
      body: adminProv.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => adminProv.fetchAdminData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('system_overview'),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          AppLocalizations.of(context)!.translate('total_users'),
                          "${adminProv.stats['total_users'] ?? 0}",
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          AppLocalizations.of(context)!.translate('db_status'),
                          adminProv.stats['db_status'] ?? 'Offline',
                          Icons.storage,
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.translate('management_modules'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildAdminAction(
                          context,
                          "User Control",
                          Icons.manage_accounts,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                        ),
                        _buildAdminAction(
                          context,
                          "System Logs",
                          Icons.list_alt,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemLogsScreen())),
                        ),
                        _buildAdminAction(context, "Database", Icons.dns, () {}),
                        _buildAdminAction(context, "Alerts/Security", Icons.security, () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- HELPER METHODS ---

 // lib/screens/admin/admin_dashboard_screen.dart

Widget _buildAdminDrawer(BuildContext context, AuthProvider auth) {
  final user = auth.currentUser;
  return Drawer(
    child: Column(
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(user?.username ?? 'Admin'),
          accountEmail: Text(user?.email ?? ''),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(user?.username[0].toUpperCase() ?? 'A', 
                style: const TextStyle(fontSize: 24, color: Colors.blue)),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout", style: TextStyle(color: Colors.red)),
          onTap: () async {
            // 1. Perform the logout logic (clearing tokens/session)
            await auth.logout();

            if (context.mounted) {
              // 2. Show a confirmation message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Admin logged out successfully')),
              );

              // 3. Clear the navigation stack and move to AuthScreen
              // This ensures the user cannot "go back" to the dashboard
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
    ),
  );
}


  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // THE MISSING METHOD
  Widget _buildAdminAction(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: GlassMorphism(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}