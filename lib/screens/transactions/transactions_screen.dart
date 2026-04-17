// lib/screens/transactions/transactions_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/animated_card.dart';
import '../../localization/app_localizations.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Income', 'Expenses', 'Transfers'];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            AnimatedCard(
              delay: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'search'.tr(context),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            
            // Filter Chips
            AnimatedCard(
              delay: 100,
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter.tr(context)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: Theme.of(context).cardColor,
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Transaction List
            AnimatedCard(
              delay: 200,
              child: Column(
                children: [
                  _buildTransactionHistoryItem(
                    'Salary Deposit',
                    '+TSh 3,200,000',
                    'Income',
                    'Today, 14:30',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  _buildTransactionHistoryItem(
                    'Shoppers Plaza',
                    '-TSh 124,000',
                    'Shopping',
                    'Yesterday, 18:45',
                    Icons.shopping_bag,
                    Colors.red,
                  ),
                  _buildTransactionHistoryItem(
                    'TANESCO',
                    '-TSh 50,000',
                    'Utilities',
                    'Dec 24, 2024',
                    Icons.electric_bolt,
                    Colors.red,
                  ),
                  _buildTransactionHistoryItem(
                    'Transfer to Savings',
                    '-TSh 500,000',
                    'Transfer',
                    'Dec 23, 2024',
                    Icons.swap_horiz,
                    Colors.orange,
                  ),
                  _buildTransactionHistoryItem(
                    'Freelance Payment',
                    '+TSh 850,000',
                    'Income',
                    'Dec 22, 2024',
                    Icons.work,
                    Colors.green,
                  ),
                ],
              ),
            ),
            
            // Add Transaction Button
            const SizedBox(height: 16),
            AnimatedCard(
              delay: 300,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddTransactionDialog();
                },
                icon: const Icon(Icons.add),
                label: Text('add_transaction'.tr(context)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistoryItem(
    String title,
    String amount,
    String category,
    String date,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'add_transaction'.tr(context),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'transaction_type'.tr(context)),
                items: ['Income', 'Expense', 'Transfer'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.tr(context)));
                }).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'amount'.tr(context)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'category'.tr(context)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'description'.tr(context)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text('save'.tr(context)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}