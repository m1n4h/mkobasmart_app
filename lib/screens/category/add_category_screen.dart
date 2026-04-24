import 'package:flutter/material.dart';

import 'package:mkobasmart_app/provider/category_provider.dart';
import 'package:mkobasmart_app/widgets/customer_header.dart';
import 'package:provider/provider.dart';


class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'expense';
  String _selectedColor = '#2E7D32'; // Default Green

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(title: "Add Category", showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What is this category for?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "e.g. Sales, Rent, Stock",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Type", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                _typeChip('expense', 'Expense', Colors.red),
                const SizedBox(width: 10),
                _typeChip('income', 'Income', Colors.green),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save Category", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, Color color) {
    bool isSelected = _selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedType = value);
      },
      selectedColor: color.withOpacity(0.3),
      labelStyle: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold),
    );
  }

  void _submit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name")),
      );
      return;
    }

    // Call the correct provider method to save to Django
    final result = await Provider.of<CategoryProvider>(context, listen: false)
        .addCategory(
      _nameController.text,
      _selectedType,
      _selectedColor,
      "category", // Default icon
    );

    if (result['success']) {
      if (mounted) Navigator.pop(context); // Go back to list
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? "Failed to save")),
        );
      }
    }
  }
}