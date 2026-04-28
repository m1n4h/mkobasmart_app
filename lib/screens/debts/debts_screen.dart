// lib/screens/debts/debts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/animated_card.dart';
import '../../localization/app_localizations.dart';
import '../../provider/debt_provider.dart';
import '../../models/debt_model.dart';
import '../../utils/auth_guard.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  
  // Add this listener to force the UI to update when the tab changes
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
    await _loadDebts();
  }

  Future<void> _loadDebts() async {
    final provider = Provider.of<DebtProvider>(context, listen: false);
    await provider.fetchDebts();
  }

  void _showAddDebtDialog() {
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    double totalAmount = 0;
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));
    String debtType = 'loan';
    bool isOwedToMe = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
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
                        'Add New Debt',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Smart Edit: If you edit the Total Amount, the Remaining Balance will update automatically.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),

                      // Debt Type Toggle
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'owed_to_me', label: Text('Owed to Me')),
                          ButtonSegment(value: 'i_owe', label: Text('I Owe')),
                        ],
                        selected: {isOwedToMe ? 'owed_to_me' : 'i_owe'},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            isOwedToMe = newSelection.first == 'owed_to_me';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter title';
                          }
                          return null;
                        },
                        onSaved: (value) => title = value!,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                        onSaved: (value) => description = value ?? '',
                      ),
                      const SizedBox(height: 16),

                      // Total Amount
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Total Amount (TSh)',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          return null;
                        },
                        onSaved: (value) => totalAmount = double.parse(value!),
                      ),
                      const SizedBox(height: 16),

                      // Debt Type
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Debt Type',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: debtType,
                        items: const [
                          DropdownMenuItem(value: 'loan', child: Text('Loan')),
                          DropdownMenuItem(
                              value: 'credit_card', child: Text('Credit Card')),
                          DropdownMenuItem(
                              value: 'other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            debtType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Due Date
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Due Date'),
                        subtitle: Text(_formatDate(dueDate)),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              dueDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text('Cancel'.tr(context)),
                            ),
                          ),
                          const SizedBox(width: 12),
                         
                         ElevatedButton(
  onPressed: () async { // Make this async
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newDebt = Debt(
        id: 0,
        counterpartyName: title, // This maps to 'title' in your form
        debtType: debtType,
        isOwedToMe: isOwedToMe,
        totalAmount: totalAmount,
        remainingAmount: totalAmount,
        description: description,
        dueDate: dueDate,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await Provider.of<DebtProvider>(context, listen: false).addDebt(newDebt);

      if (success) {
        if (mounted) Navigator.pop(context);
        // The provider's addDebt already calls fetchDebts(), 
        // so the Consumer will handle the update.
      }
    }
  },
  child: Text('Save'.tr(context)),
),

                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveDebt({
    required int id,
    required String counterpartyName,
    required String debtType,
    required bool isOwedToMe,
    required double totalAmount,
    required double remainingAmount,
    required String description,
    required DateTime dueDate,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String title,
  }) async {
    final debt = Debt(
      id: id,
      counterpartyName: title,
      debtType: debtType,
      isOwedToMe: isOwedToMe,
      totalAmount: totalAmount,
      remainingAmount: totalAmount,
      description: description,
      dueDate: dueDate,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = Provider.of<DebtProvider>(context, listen: false);
    final success = await provider.addDebt(debt);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debt added successfully!')),
      );
      _loadDebts();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to add debt')),
      );
    }
  }

  void _showMakePaymentDialog(Debt debt) {
    final _formKey = GlobalKey<FormState>();
    double amount = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Make Payment for ${debt.counterpartyName}'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Remaining: TSh ${debt.remainingAmount.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Payment Amount (TSh)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    final amt = double.tryParse(value);
                    if (amt == null) {
                      return 'Invalid amount';
                    }
                    if (amt > debt.remainingAmount) {
                      return 'Amount exceeds remaining balance';
                    }
                    return null;
                  },
                  onSaved: (value) => amount = double.parse(value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr(context)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(context);

                  final provider =
                      Provider.of<DebtProvider>(context, listen: false);
                  final success = await provider.makePayment(debt.id, amount);

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Payment recorded successfully!')),
                    );
                    _loadDebts();
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              provider.error ?? 'Failed to record payment')),
                    );
                  }
                }
              },
              child: Text('Pay'.tr(context)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final debtProvider = Provider.of<DebtProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary Cards
            AnimatedCard(
              delay: 0,
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Owed to Me',
                      'TSh ${debtProvider.totalOwedToMe.toStringAsFixed(0)}',
                      '${debtProvider.activeDebtsOwed} active debtors',
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total I Owe',
                      'TSh ${debtProvider.totalIOwe.toStringAsFixed(0)}',
                      '${debtProvider.activeDebtsToPay} creditors',
                      Icons.account_balance,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Selector
            AnimatedCard(
              delay: 50,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    Tab(text: 'Owed to Me'.tr(context)),
                    Tab(text: 'I Owe'.tr(context)),
                  ],
                ),
              ),
            ),

            // Debt List
            AnimatedCard(
              delay: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showAddDebtDialog,
                          icon: const Icon(Icons.add),
                          label: Text('Add New Debt'.tr(context)),
                        ),
                      ],
                    ),
                  ),
                  // Use a Consumer to listen to DebtProvider changes
Consumer<DebtProvider>(
  builder: (context, provider, child) {
    // Determine the list based on the current tab index
    final displayList = _tabController.index == 0
        ? provider.debtsOwedToMe
        : provider.debtsIOwe;

    if (displayList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No debt records found in this category"),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        return _buildDebtItem(displayList[index]);
      },
    );
  },
),
                ],
              ),
            ),

            // Debt Health Card (derived from backend totals)
            AnimatedCard(
              delay: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.health_and_safety,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          const Text(
                            'Debt-to-Income Health',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        debtProvider.totalOwedToMe == 0
                            ? 'No debt data available yet.'
                            : 'Debt balance ratio: ${((debtProvider.totalIOwe / debtProvider.totalOwedToMe) * 100).toStringAsFixed(1)}%',
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trust Score',
                              style: TextStyle(color: Colors.white)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Text(
                            '${(1000 - (debtProvider.totalIOwe / (debtProvider.totalOwedToMe == 0 ? 1 : debtProvider.totalOwedToMe) * 100)).clamp(300, 999).toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, String subtitle,
      IconData icon, Color color) {
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
              Text(title, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildDebtItem(Debt debt) {
    final isOverdue =
        debt.dueDate.isBefore(DateTime.now()) && debt.status != 'paid';
    final statusColor = debt.status == 'paid'
        ? Colors.green
        : isOverdue
            ? Colors.red
            : Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              debt.debtType == 'loan'
                  ? Icons.account_balance
                  : Icons.credit_card,
              color: statusColor,
            ),
          ),
          title: Text(
            debt.counterpartyName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Due: ${_formatDate(debt.dueDate)}',
                style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? Colors.red : Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (debt.totalAmount - debt.remainingAmount) /
                    debt.totalAmount,
                backgroundColor: Colors.grey[300],
                color: statusColor,
                borderRadius: BorderRadius.circular(10),
                minHeight: 4,
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TSh ${debt.remainingAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  debt.status == 'paid'
                      ? 'Paid'
                      : isOverdue
                          ? 'Overdue'
                          : debt.status,
                  style: TextStyle(fontSize: 10, color: statusColor),
                ),
              ),
            ],
          ),
          onTap: () => _showMakePaymentDialog(debt),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
