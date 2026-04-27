// lib/models/category_model.dart
class Category {
  final int id;
  final String name;
  final String categoryType;
  final String? icon;
  final String color;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.categoryType,
    this.icon,
    required this.color,
    required this.isDefault,
  });

 factory Category.fromJson(Map<String, dynamic> json) {
  return Category(
    id: json['id'] ?? 0,
    name: json['name'] ?? 'Unnamed',
    categoryType: (json['category_type'] as String).toLowerCase(),
    icon: json['icon'],
    color: (json['color'] != null && json['color'].toString().startsWith('#')) 
        ? json['color'] 
        : '#2E7D32',
    isDefault: json['is_default'] ?? false,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_type': categoryType,
      'icon': icon,
      'color': color,
    };
  }
}