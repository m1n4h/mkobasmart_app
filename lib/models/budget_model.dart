class Budget {
  final int id;
  final int categoryId;
  final String categoryName;
  final double amount;
  final double spentAmount;
  final double remainingAmount;
  final double percentageUsed;
  final int month;
  final int year;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentageUsed,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryId: json['category'],
      categoryName: json['category_name'] ?? '',
      amount: double.parse(json['amount'].toString()),
      spentAmount: double.parse(json['spent_amount'].toString()),
      remainingAmount: double.parse(json['remaining_amount'].toString()),
      percentageUsed: double.parse(json['percentage_used'].toString()),
      month: json['month'],
      year: json['year'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'category': categoryId,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }
}