// lib/screens/debts/debts_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/animated_card.dart';
import '../../localization/app_localizations.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  int _selectedTab = 0; // 0: Owed to me, 1: I owe

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Tab Selector
          AnimatedCard(
            delay: 0,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'money_owed_to_me'.tr(context),
                          style: TextStyle(
                            color: _selectedTab == 0 ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'money_i_owe'.tr(context),
                          style: TextStyle(
                            color: _selectedTab == 1 ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Summary Cards
          AnimatedCard(
            delay: 100,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.green.shade700],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTab == 0 ? 'Total Owed' : 'Total Debt',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedTab == 0 ? 'TSh 2,450,000' : 'TSh 1,280,000',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.orange.shade700],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTab == 0 ? 'Due This Month' : 'Payment Due',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedTab == 0 ? 'TSh 450,000' : 'TSh 280,000',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Debt List
          AnimatedCard(
            delay: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTab == 0 ? 'lenders'.tr(context) : 'borrowers'.tr(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: Text('Add'),
                    ),
                  ],
                ),
                _buildDebtItem(
                  name: 'John Mbowe',
                  amount: 'TSh 500,000',
                  dueDate: 'Due: Dec 30, 2024',
                  status: 'On Time',
                  color: Colors.green,
                ),
                _buildDebtItem(
                  name: 'Sarah Hmara',
                  amount: 'TSh 750,000',
                  dueDate: 'Due: Jan 15, 2025',
                  status: 'Upcoming',
                  color: Colors.orange,
                ),
                _buildDebtItem(
                  name: 'Kigoma Traders',
                  amount: 'TSh 1,200,000',
                  dueDate: 'Due: Jan 5, 2025',
                  status: 'Pending',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          
          // Payment Reminder
          AnimatedCard(
            delay: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.white),
                title: const Text(
                  'Payment Reminder',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'You have 3 payments due this week',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                  ),
                  child: const Text('View'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtItem({
    required String name,
    required String amount,
    required String dueDate,
    required String status,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(dueDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}