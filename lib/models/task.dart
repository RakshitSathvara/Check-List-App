class Task {
  final String id;
  final String name;
  final String category;
  final String timeRemaining;
  final bool isCompleted;
  final String specificationRange;
  final bool isRange;
  final String? completedAt;

  Task({
    required this.id,
    required this.name,
    required this.category,
    required this.timeRemaining,
    this.isCompleted = false,
    required this.specificationRange,
    required this.isRange,
    this.completedAt,
  });
  
  // Add copyWith method to create a new instance with modified properties
  Task copyWith({
    String? id,
    String? name,
    String? category,
    String? timeRemaining,
    bool? isCompleted,
    String? specificationRange,
    bool? isRange,
    String? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isCompleted: isCompleted ?? this.isCompleted,
      specificationRange: specificationRange ?? this.specificationRange,
      isRange: isRange ?? this.isRange,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}