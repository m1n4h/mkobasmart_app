import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mkobasmart_app/provider/category_provider.dart';
import 'package:mkobasmart_app/models/category_model.dart';
import 'package:mkobasmart_app/widgets/customer_header.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _transactionType = 'expense'; // 'income' or 'expense'
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- LOGIC: Filter categories based on transaction type selection ---
    List<Category> filteredCategories = _transactionType == 'income'
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;

    return Scaffold(
      appBar: const CustomHeader(title: "New Record", showBackButton: true),
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Toggle Type
              Row(
                children: [
                  _buildTypeOption("Expense", "expense", Colors.red),
                  const SizedBox(width: 15),
                  _buildTypeOption("Income", "income", Colors.green),
                ],
              ),
              const SizedBox(height: 25),

              // 2. Amount Input
              const Text("How much?", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: "TZS ",
                  hintText: "0.00",
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (val) => val!.isEmpty ? "Please enter amount" : null,
              ),
              const SizedBox(height: 25),

              // 3. Category Dropdown (The Filtered Part)
              const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                hint: const Text("Select category"),
                items: filteredCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (val) => val == null ? "Select a category" : null,
              ),
              const SizedBox(height: 25),

              // 4. Note
              const Text("Note", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: "What was this for?",
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 40),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _transactionType == 'income' ? Colors.green : Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Save Transaction", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(String label, String value, Color color) {
    bool isSelected = _transactionType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _transactionType = value;
          _selectedCategoryId = null; // Reset selection when switching types
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      // Logic to call your TransactionProvider goes here
      print("Type: $_transactionType, Category: $_selectedCategoryId, Amount: ${_amountController.text}");
    }
  }
}