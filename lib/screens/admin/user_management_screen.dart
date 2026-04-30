import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Mock data - In a real app, you would fetch this from your Django API
  final List<Map<String, dynamic>> _users = [
    {'name': 'Amina Juma', 'email': 'amina@gmail.com', 'status': 'Active', 'role': 'User'},
    {'name': 'John Doe', 'email': 'john@mkobasmart.com', 'status': 'Active', 'role': 'Admin'},
    {'name': 'Guest_123', 'email': 'guest123@guest.com', 'status': 'Inactive', 'role': 'Guest'},
  ];

  void _handleUserAction(String action, String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action: $action performed on $email'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user['role'] == 'Admin' ? Colors.orange : Colors.green,
                child: Text(user['name'][0]),
              ),
              title: Text(user['name']),
              subtitle: Text("${user['email']} • ${user['role']}"),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleUserAction(value, user['email']),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Edit', child: Text('Edit details')),
                  const PopupMenuItem(value: 'Deactivate', child: Text('Deactivate Account', style: TextStyle(color: Colors.orange))),
                  const PopupMenuItem(value: 'Delete', child: Text('Delete Permanent', style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}