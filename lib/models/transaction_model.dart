// lib/models/transaction_model.dart
class Transaction {
  final int id;
  final String transactionType;
  final int? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;
  final double amount;
  final String description;
  final DateTime date;
  final String? receiptImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.transactionType,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    required this.amount,
    required this.description,
    required this.date,
    this.receiptImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      transactionType: json['transaction_type'] ?? 'expense',
      categoryId: json['category'],
      categoryName: json['category_name'],
      categoryColor: json['category_color'],
      categoryIcon: json['category_icon'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      receiptImage: json['receipt_image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_type': transactionType,
      'category': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'receipt_image': receiptImage,
    };
  }
}
