// lib/models/debt_model.dart
class Debt {
  final int id;
  final String counterpartyName;
  final String debtType;
  final bool isOwedToMe;
  final double totalAmount;
  final double remainingAmount;
  final String description;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Debt({
    required this.id,
    required this.counterpartyName,
    required this.debtType,
    required this.isOwedToMe,
    required this.totalAmount,
    required this.remainingAmount,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      counterpartyName: json['counterparty_name'] ?? '',
      debtType: json['debt_type'] ?? 'other',
      isOwedToMe: json['is_owed_to_me'] ?? false,
      totalAmount: double.parse(json['total_amount'].toString()),
      remainingAmount: double.parse(json['remaining_amount'].toString()),
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'counterparty_name': counterpartyName,
      'debt_type': debtType,
      'is_owed_to_me': isOwedToMe,
      'total_amount': totalAmount,
      'description': description,
      'due_date': dueDate.toIso8601String(),
    };
  }
}