import 'package:flutter/material.dart';
import 'package:mkobasmart_app/screens/admin/user_management_screen.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/glass_morphism.dart';
import '../authentication/auth_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Central Command'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("System Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // KPI Section
            Row(
              children: [
                _buildStatCard("Total Users", "1,240", Icons.people, Colors.blue),
                _buildStatCard("Transactions", "Tsh 4.5M", Icons.account_balance, Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            
            const Text("Management Modules", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Grid of Controls
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildAdminAction(context, "User Control", Icons.manage_accounts, () {
                  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const UserManagementScreen()),
  );
                }),
                _buildAdminAction(context, "System Logs", Icons.list_alt, () {}),
                _buildAdminAction(context, "Database", Icons.storage, () {}),
                _buildAdminAction(context, "Alerts/Security", Icons.security, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminAction(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: GlassMorphism(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}