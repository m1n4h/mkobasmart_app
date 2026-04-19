// lib/services/storage_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<String> saveImage(File image, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/images/$name.jpg';
    final file = File(path);
    await file.create(recursive: true);
    await image.copy(path);
    return path;
  }

  static Future<File?> getImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  static Future<void> saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in data.entries) {
      await prefs.setString(entry.key, entry.value.toString());
    }
  }

  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, String> data = {};
    for (var key in keys) {
      data[key] = prefs.getString(key) ?? '';
    }
    return data;
  }
}