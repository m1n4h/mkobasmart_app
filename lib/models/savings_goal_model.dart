// lib/models/savings_goal_model.dart

class SavingsGoal {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'],
      name: json['name'] ?? '',
      targetAmount: double.parse(json['target_amount'].toString()),
      currentAmount: double.parse(json['current_amount'].toString()),
      deadline: DateTime.parse(json['deadline']),
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'description': description,
    };
  }

  // Helper properties
  double get remainingAmount => targetAmount - currentAmount;
  
  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount) * 100;
  }
  
  bool get isCompleted => currentAmount >= targetAmount;
  
  bool get isOverdue => deadline.isBefore(DateTime.now()) && !isCompleted;
  
  int get daysRemaining {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }
  
  String get formattedDeadline {
    return '${deadline.day}/${deadline.month}/${deadline.year}';
  }
  
  String get formattedTargetAmount {
    return 'TSh ${targetAmount.toStringAsFixed(0)}';
  }
  
  String get formattedCurrentAmount {
    return 'TSh ${currentAmount.toStringAsFixed(0)}';
  }
  
  String get formattedRemainingAmount {
    return 'TSh ${remainingAmount.toStringAsFixed(0)}';
  }
  
  String get formattedProgressPercentage {
    return '${progressPercentage.toStringAsFixed(1)}%';
  }

  // Create a copy with updated values
  SavingsGoal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SavingsGoal(id: $id, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsGoal &&
        other.id == id &&
        other.name == name &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.deadline == deadline;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        deadline.hashCode;
  }
}

// For creating a new savings goal (without ID)
class CreateSavingsGoalRequest {
  final String name;
  final double targetAmount;
  final DateTime deadline;
  final String description;

  CreateSavingsGoalRequest({
    required this.name,
    required this.targetAmount,
    required this.deadline,
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target_amount': targetAmount,
      'deadline': deadline.toIso8601String(),
      'description': description,
    };
  }
}

// For adding savings to a goal
class AddSavingsRequest {
  final int goalId;
  final double amount;

  AddSavingsRequest({
    required this.goalId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
    };
  }
}

// For updating a savings goal
class UpdateSavingsGoalRequest {
  final int id;
  final String? name;
  final double? targetAmount;
  final DateTime? deadline;
  final String? description;

  UpdateSavingsGoalRequest({
    required this.id,
    this.name,
    this.targetAmount,
    this.deadline,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target_amount': targetAmount,
      'deadline': deadline?.toIso8601String(),
      'description': description,
    }..removeWhere((key, value) => value == null);
  }
}

// Savings goal summary
class SavingsGoalSummary {
  final double totalTargetAmount;
  final double totalCurrentAmount;
  final int totalGoals;
  final int completedGoals;
  final int activeGoals;
  final int overdueGoals;

  SavingsGoalSummary({
    required this.totalTargetAmount,
    required this.totalCurrentAmount,
    required this.totalGoals,
    required this.completedGoals,
    required this.activeGoals,
    required this.overdueGoals,
  });

  factory SavingsGoalSummary.fromList(List<SavingsGoal> goals) {
    double totalTarget = 0;
    double totalCurrent = 0;
    int completed = 0;
    int active = 0;
    int overdue = 0;

    for (var goal in goals) {
      totalTarget += goal.targetAmount;
      totalCurrent += goal.currentAmount;
      
      if (goal.isCompleted) {
        completed++;
      } else if (goal.isOverdue) {
        overdue++;
      } else {
        active++;
      }
    }

    return SavingsGoalSummary(
      totalTargetAmount: totalTarget,
      totalCurrentAmount: totalCurrent,
      totalGoals: goals.length,
      completedGoals: completed,
      activeGoals: active,
      overdueGoals: overdue,
    );
  }

  double get overallProgressPercentage {
    if (totalTargetAmount <= 0) return 0;
    return (totalCurrentAmount / totalTargetAmount) * 100;
  }

  double get totalRemainingAmount => totalTargetAmount - totalCurrentAmount;

  String get formattedTotalTarget => 'TSh ${totalTargetAmount.toStringAsFixed(0)}';
  String get formattedTotalCurrent => 'TSh ${totalCurrentAmount.toStringAsFixed(0)}';
  String get formattedTotalRemaining => 'TSh ${totalRemainingAmount.toStringAsFixed(0)}';
  String get formattedOverallProgress => '${overallProgressPercentage.toStringAsFixed(1)}%';
}