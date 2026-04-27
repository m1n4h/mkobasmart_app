// lib/screens/transactions/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:mkobasmart_app/provider/category_provider.dart';
import 'package:mkobasmart_app/screens/category/category_list_screen.dart';
import 'package:provider/provider.dart';
import '../../widgets/animated_card.dart';
import '../../localization/app_localizations.dart';
import '../../provider/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../utils/auth_guard.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month'];
  final TextEditingController _searchController = TextEditingController();

 @override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  
  // ADD THIS: Re-build the list when the tab changes
  _tabController.addListener(() {
    if (!_tabController.indexIsChanging) {
      setState(() {}); 
    }
  });
  
  _initialize();
}

Future<void> _initialize() async {
  final ok = await AuthGuard.ensureAuthenticated(context);
  if (!ok) return;
  
  // Load both transactions and categories
  final transProvider = Provider.of<TransactionProvider>(context, listen: false);
  final catProvider = Provider.of<CategoryProvider>(context, listen: false);
  
  await Future.wait([
    transProvider.fetchTransactions(),
    catProvider.fetchCategories(),
  ]);
}
  
  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    
    return Scaffold(
      body: Column(
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
                      onChanged: (value) {
                        transactionProvider.searchTransactions(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterDialog(),
                  ),
                ],
              ),
            ),
          ),

          // ... after Search Bar Container ...
const SizedBox(height: 16),
GestureDetector(
  onTap: () => Navigator.push(
    context, 
    MaterialPageRoute(builder: (_) => const CategoryListScreen())
  ),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      // Dark Mode & Light Mode support
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF2C2C2C) 
          : Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.category_outlined, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "manage_categories".tr(context),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "add_or_edit_shop_items".tr(context),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
    ),
  ),
),
const SizedBox(height: 16),

          // Filter Chips
          AnimatedCard(
            delay: 100,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        transactionProvider.filterByPeriod(filter);
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
          
          // Income/Expense Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              tabs: [
                Tab(text: 'Expenses'.tr(context)),
                Tab(text: 'Income'.tr(context)),
              ],
            ),
          ),
          
          // Summary Cards
          AnimatedCard(
            delay: 150,
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expenses',
                    'TSh ${transactionProvider.totalExpenses.toStringAsFixed(0)}',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Income',
                    'TSh ${transactionProvider.totalIncome.toStringAsFixed(0)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          // Transaction List
          Expanded(
            child: transactionProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tabController.index == 0
                    ? _buildTransactionList(transactionProvider.filteredTransactions
                        .where((t) => t.transactionType == 'expense')
                        .toList())
                    : _buildTransactionList(transactionProvider.filteredTransactions
                        .where((t) => t.transactionType == 'income')
                        .toList()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          ).then((_) => _initialize());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isExpense = transaction.transactionType == 'expense';
        return AnimatedCard(
          delay: index * 50,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(transaction.categoryName),
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
            title: Text(transaction.description),
            subtitle: Text(
              '${transaction.categoryName} • ${_formatDate(transaction.date)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Text(
              '${isExpense ? '-' : '+'}TSh ${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
            onTap: () => _showTransactionDetails(transaction),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'salary': return Icons.attach_money;
      case 'groceries': return Icons.shopping_cart;
      case 'transport': return Icons.directions_car;
      case 'utilities': return Icons.bolt;
      case 'entertainment': return Icons.movie;
      default: return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date.isAfter(today)) {
      return 'Today, ${_formatTime(date)}';
    } else if (date.isAfter(yesterday)) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filter Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildFilterOption('All Transactions', () {}),
              _buildFilterOption('Income Only', () {}),
              _buildFilterOption('Expenses Only', () {}),
              _buildFilterOption('By Category', () {}),
              _buildFilterOption('By Date Range', () {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
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
                transaction.description,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Amount', 'TSh ${transaction.amount.toStringAsFixed(0)}'),
              _buildDetailRow('Category', transaction.categoryName ?? 'N/A'),
              _buildDetailRow('Date', _formatDate(transaction.date)),
              _buildDetailRow('Type', transaction.transactionType),
              if (transaction.description.isNotEmpty)
                _buildDetailRow('Description', transaction.description),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditTransactionDialog(transaction);
                      },
                      icon: const Icon(Icons.edit),
                      label: Text('Edit'.tr(context)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteTransaction(transaction);
                      },
                      icon: const Icon(Icons.delete),
                      label: Text('Delete'.tr(context)),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTransaction(Transaction transaction) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text('Are you sure you want to delete this transaction?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;
    final deleted = await provider.deleteTransaction(transaction.id!);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deleted ? 'Transaction deleted' : (provider.error ?? 'Failed to delete transaction')),
      ),
    );
  }

  Future<void> _showEditTransactionDialog(Transaction transaction) async {
    final amountController =
        TextEditingController(text: transaction.amount.toStringAsFixed(0));
    final descriptionController = TextEditingController(text: transaction.description);
    DateTime selectedDate = transaction.date;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Transaction'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Amount'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Amount is required';
                          if (double.tryParse(value.trim()) == null) return 'Enter valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        subtitle: Text(_formatDate(selectedDate)),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                selectedDate.hour,
                                selectedDate.minute,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final provider = Provider.of<TransactionProvider>(this.context, listen: false);
                    final updated = Transaction(
                      id: transaction.id,
  transactionType: transaction.transactionType,
  categoryId: transaction.categoryId, // This maps to the backend 'category' ID
  categoryName: transaction.categoryName,
  categoryColor: transaction.categoryColor,
  categoryIcon: transaction.categoryIcon,
  amount: double.parse(amountController.text.trim()),
  description: descriptionController.text.trim(),
  date: selectedDate,
  receiptImage: transaction.receiptImage,
  createdAt: transaction.createdAt,
  updatedAt: DateTime.now(),
                      
                    );

                    final ok = await provider.updateTransaction(updated);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Transaction updated' : (provider.error ?? 'Failed to update transaction')),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}