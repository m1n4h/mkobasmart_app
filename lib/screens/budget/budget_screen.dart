// lib/screens/budget/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/animated_card.dart';
import '../../localization/app_localizations.dart';
import '../../provider/budget_provider.dart';
import '../../models/budget_model.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart';
import '../../utils/auth_guard.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final CategoryService _categoryService = CategoryService();
  Map<String, int> _categoryIdMap = {};
  List<Category> _categories = [];
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final ok = await AuthGuard.ensureAuthenticated(context);
    if (!ok) return;
    await _loadBudgets();
    await _loadCategories();
  }

  Future<void> _loadBudgets() async {
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    await provider.fetchBudgets();
  }
  
  Future<void> _loadCategories() async {
    final categories = await _categoryService.getCategories();
    final Map<String, int> map = {};
    for (var category in categories) {
      if (category.categoryType == 'expense') {
        map[category.name] = category.id;
      }
    }
    setState(() {
      _categoryIdMap = map;
      _categories = categories.where((c) => c.categoryType == 'expense').toList();
    });
  }

  void _showAddBudgetDialog() {
    final _formKey = GlobalKey<FormState>();
    String selectedCategory = '';
    double budgetAmount = 0;
    
    final List<String> categories = _categories.map((c) => c.name).toList();
    
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
                      'Set Budget',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Category Selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: selectedCategory.isEmpty ? null : selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Budget Amount
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Budget Amount (TSh)',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter budget amount';
                        }
                        return null;
                      },
                      onSaved: (value) => budgetAmount = double.parse(value!),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Cancel'.tr(context)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _saveBudget(
                                  categoryName: selectedCategory,
                                  amount: budgetAmount,
                                );
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Save'.tr(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveBudget({
    required String categoryName,
    required double amount,
  }) async {
    // Get category ID from the map
    final categoryId = _categoryIdMap[categoryName];
    
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category not found. Please try again.')),
      );
      return;
    }
    
    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch,
      categoryId: categoryId,  // Now passing int, not String
      categoryName: categoryName,
      amount: amount,
      spentAmount: 0,
      remainingAmount: amount,
      percentageUsed: 0,
      month: DateTime.now().month,
      year: DateTime.now().year,
      createdAt: DateTime.now(),
    );
    
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final success = await provider.addBudget(budget);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget set successfully!')),
      );
      _loadBudgets();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to set budget')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Budget Overview Chart
            AnimatedCard(
              delay: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget Overview',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddBudgetDialog,
                        icon: const Icon(Icons.add),
                        label: Text('Set Budget'.tr(context)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildBudgetChart(budgetProvider.budgets),
                  ),
                ],
              ),
            ),
            
            // Monthly Summary
            AnimatedCard(
              delay: 100,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.teal.shade700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Summary',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Budget',
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                            Text(
                              'TSh ${budgetProvider.totalBudget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Spent',
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                            Text(
                              'TSh ${budgetProvider.totalSpent.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: budgetProvider.totalBudget > 0
                          ? budgetProvider.totalSpent / budgetProvider.totalBudget
                          : 0,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${((budgetProvider.totalSpent / (budgetProvider.totalBudget > 0 ? budgetProvider.totalBudget : 1)) * 100).toStringAsFixed(1)}% used',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ),
            
            // Category Budgets List
            AnimatedCard(
              delay: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Budgets',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  budgetProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : budgetProvider.budgets.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 40),
                                  Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No budgets set yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _showAddBudgetDialog,
                                    child: Text('Create Budget'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: budgetProvider.budgets.length,
                              itemBuilder: (context, index) {
                                final budget = budgetProvider.budgets[index];
                                return _buildBudgetItem(budget);
                              },
                            ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetChart(List<Budget> budgets) {
    return Center(
      child: budgets.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart, size: 50, color: Colors.grey),
                const SizedBox(height: 8),
                Text('No data to display', style: TextStyle(color: Colors.grey)),
              ],
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: budgets.map((budget) {
                final percentage = budget.spentAmount / budget.amount;
                final color = percentage > 1
                    ? Colors.red
                    : percentage > 0.8
                        ? Colors.orange
                        : Colors.green;
                return Container(
                  width: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        budget.categoryName,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(percentage * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildBudgetItem(Budget budget) {
    final spentAmount = budget.spentAmount;
    final percentage = spentAmount / budget.amount;
    final isOver = spentAmount > budget.amount;
    final color = isOver ? Colors.red : percentage > 0.8 ? Colors.orange : Colors.green;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(budget.categoryName, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                'TSh ${spentAmount.toStringAsFixed(0)} / TSh ${budget.amount.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 12, color: isOver ? Colors.red : Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage > 1 ? 1 : percentage,
            backgroundColor: Colors.grey[300],
            color: color,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining: TSh ${(budget.amount - spentAmount).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 10, color: isOver ? Colors.red : Colors.grey[600]),
              ),
              if (isOver)
                Text(
                  'Over Budget!',
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }
}