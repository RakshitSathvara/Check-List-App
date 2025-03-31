class Task {
  final String id;
  final String name;
  final String category;
  final String timeRemaining;
  final bool isCompleted;

  Task({
    required this.id,
    required this.name,
    required this.category,
    required this.timeRemaining,
    this.isCompleted = false,
  });
}