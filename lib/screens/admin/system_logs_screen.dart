// lib/screens/admin/system_logs_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/admin_provider.dart';

class SystemLogsScreen extends StatelessWidget {
  const SystemLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final logs = adminProv.logs;

    return Scaffold(
      appBar: AppBar(title: const Text("Real-time System Logs")),
      body: logs.isEmpty 
        ? const Center(child: Text("No logs recorded today."))
        : ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: Icon(
                  log['level'] == 'SECURITY' ? Icons.warning : Icons.info_outline,
                  color: log['level'] == 'SECURITY' ? Colors.red : Colors.blue,
                ),
                title: Text(log['message']),
                subtitle: Text("${log['user']} • ${log['timestamp']}"),
                trailing: Text(log['level'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              );
            },
          ),
    );
  }
}