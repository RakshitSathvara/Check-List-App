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
}