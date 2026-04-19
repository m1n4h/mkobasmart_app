// lib/services/category_service.dart
import 'dart:convert';
import '../models/category_model.dart';
import 'api_service.dart';

class CategoryService {
  Future<List<Category>> getCategories() async {
    try {
      final response = await ApiService.get('/categories/');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> createCategory(Category category) async {
    try {
      final response = await ApiService.post('/categories/', category.toJson());
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'error': 'Failed to create category'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}