// lib/screens/admin/user_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/admin_provider.dart';
import '../../models/user_model.dart'; // Ensure you import your User model

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  
  

@override
void initState() {
  super.initState();
  // This triggers the fetch as soon as the admin opens the screen
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AdminProvider>().fetchAdminData();
  });
}

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final users = adminProv.users; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showUserForm(context), // CREATE
          )
        ],
      ),
      body: adminProv.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty 
              ? const Center(child: Text("No users found in the system."))
              : RefreshIndicator(
                  onRefresh: () => adminProv.fetchAdminData(), // READ (Refresh)
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(user.username[0].toUpperCase()),
                        ),
                        title: Text(user.fullName),
                        subtitle: Text(user.email),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Edit') {
                              _showUserForm(context, user: user); // UPDATE
                            } else if (value == 'Delete') {
                              _confirmDelete(context, adminProv, user); // DELETE
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                            const PopupMenuItem(
                              value: 'Delete', 
                              child: Text('Delete', style: TextStyle(color: Colors.red))
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // DIALOG FOR CREATE & EDIT
  void _showUserForm(BuildContext context, {User? user}) {
    // You can navigate to a specific form screen or show a Dialog here
    // For now, let's assume you have a dedicated screen to handle the complex registration fields
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Redirecting to User Form..."))
    );
  }

  // CONFIRMATION DIALOG FOR DELETE
  void _confirmDelete(BuildContext context, AdminProvider prov, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to remove ${user.username}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              bool success = await prov.removeUser(user.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User deleted successfully"))
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}