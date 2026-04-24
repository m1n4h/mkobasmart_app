import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  // Filtered Getters for the Transaction Screen
  List<Category> get incomeCategories => 
      _categories.where((c) => c.categoryType == 'income').toList();

  List<Category> get expenseCategories => 
      _categories.where((c) => c.categoryType == 'expense').toList();

  // READ
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    
    _categories = await _categoryService.getCategories();
    
    _isLoading = false;
    notifyListeners();
  }

  // CREATE
  Future<Map<String, dynamic>> addCategory(String name, String type, String color, String icon) async {
    final newCat = Category(
      id: 0, 
      name: name,
      categoryType: type,
      color: color,
      icon: icon,
      isDefault: false,
    );

    final result = await _categoryService.createCategory(newCat);
    if (result['success']) {
      await fetchCategories(); // Refresh list after adding
    }
    return result;
  }

  // UPDATE
  Future<Map<String, dynamic>> updateExistingCategory(Category category) async {
    // This calls the service method you just fixed
    final result = await _categoryService.updateCategory(category);
    if (result['success']) {
      await fetchCategories(); // Refresh list after update
    }
    return result;
  }

  // DELETE
  Future<void> removeCategory(int id) async {
    // This matches the boolean return type of your service's deleteCategory
    final success = await _categoryService.deleteCategory(id);
    if (success) {
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    }
  }
}