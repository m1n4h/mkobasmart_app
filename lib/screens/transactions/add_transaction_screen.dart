// lib/screens/transactions/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/animated_card.dart';
import '../../localization/app_localizations.dart';
import '../../provider/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart';
import '../../utils/auth_guard.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Common fields
  String _selectedType = 'expense';
  String _selectedCategory = '';
  double _amount = 0;
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;
  final CategoryService _categoryService = CategoryService();
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initialize();
  }

  Future<void> _initialize() async {
    final ok = await AuthGuard.ensureAuthenticated(context);
    if (!ok) return;
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    final categories = await _categoryService.getCategories();
    _expenseCategories =
        categories.where((c) => c.categoryType == 'expense').toList();
    _incomeCategories =
        categories.where((c) => c.categoryType == 'income').toList();
    if (_selectedType == 'expense' && _expenseCategories.isNotEmpty) {
      _selectedCategory = _expenseCategories.first.name;
    } else if (_selectedType == 'income' && _incomeCategories.isNotEmpty) {
      _selectedCategory = _incomeCategories.first.name;
    }
    setState(() => _isLoadingCategories = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final sourceCategories =
          _selectedType == 'expense' ? _expenseCategories : _incomeCategories;
      if (sourceCategories.isEmpty || _selectedCategory.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please create a category first.')),
          );
        }
        return;
      }
      
      final transaction = Transaction(
        id: 0,
        transactionType: _selectedType,
        categoryId: sourceCategories.firstWhere((c) => c.name == _selectedCategory).id,
        categoryName: _selectedCategory,
        amount: _amount,
        description: _description,
        date: _selectedDate,
         createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
      );
      
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final success = await provider.addTransaction(transaction);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully!')),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save transaction')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == 'expense' ? _expenseCategories : _incomeCategories;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'.tr(context)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Expense'.tr(context)),
            Tab(text: 'Income'.tr(context)),
          ],
          onTap: (index) {
            final nextType = index == 0 ? 'expense' : 'income';
            final nextCategories =
                nextType == 'expense' ? _expenseCategories : _incomeCategories;
            setState(() {
              _selectedType = nextType;
              _selectedCategory =
                  nextCategories.isNotEmpty ? nextCategories.first.name : '';
            });
          },
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Field
              AnimatedCard(
                delay: 0,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Amount'.tr(context),
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
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => _amount = double.parse(value!),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Category Selection (backend categories)
              AnimatedCard(
                delay: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category'.tr(context),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    if (categories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No categories found. Please create categories first.'),
                      )
                    else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = _selectedCategory == category.name;
                        return FilterChip(
                          label: Text(category.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category.name;
                            });
                          },
                          backgroundColor: Theme.of(context).cardColor,
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              AnimatedCard(
                delay: 200,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description'.tr(context),
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                  onSaved: (value) => _description = value ?? '',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Date Picker
              AnimatedCard(
                delay: 300,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Date'.tr(context)),
                  subtitle: Text(_formatDate(_selectedDate)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Receipt Image
              AnimatedCard(
                delay: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt (Optional)'.tr(context),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _receiptImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_receiptImage!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to add receipt',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              AnimatedCard(
                delay: 500,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Save Transaction'.tr(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}