class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String emoji;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.emoji = '🎯',
  });

  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount => targetAmount - currentAmount;

  int get daysRemaining {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }

  bool get isCompleted => currentAmount >= targetAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'emoji': emoji,
    };
  }

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'],
      name: json['name'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      deadline: DateTime.parse(json['deadline']),
      emoji: json['emoji'] ?? '🎯',
    );
  }

  FinancialGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? emoji,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      emoji: emoji ?? this.emoji,
    );
  }
}
