import 'dart:convert';
import '../models/category_model.dart';
import 'api_service.dart';

class CategoryService {
  // 1. GET ALL
  Future<List<Category>> getCategories() async {
    try {
      final response = await ApiService.get('/categories/');
      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        
        List<dynamic> listData;
        if (decodedData is Map<String, dynamic>) {
          listData = decodedData['results'] ?? [];
        } else {
          listData = decodedData as List<dynamic>;
        }
        
        return listData.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
  
  // 2. CREATE
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

  // 3. UPDATE (Now properly inside the class)
  Future<Map<String, dynamic>> updateCategory(Category category) async {
    try {
      // We pass a String to ApiService.put, which is what it expects
      final response = await ApiService.put('/categories/${category.id}/', category.toJson());
      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {'success': false, 'error': 'Failed to update category'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 4. DELETE (Now properly inside the class)
  Future<bool> deleteCategory(int id) async {
    try {
      // We pass a String to ApiService.delete
      final response = await ApiService.delete('/categories/$id/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error in deleteCategory: $e');
      return false;
    }
  }
} // End of class