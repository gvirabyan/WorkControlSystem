class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final String startDate;
  final String endDate;
  final String dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
  });

  // Метод для создания Task из Map (например, Firestore)
  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'] ?? '-',
      description: data['description'] ?? '-',
      status: data['status'] ?? '-',
      startDate: data['startDate'] ?? '-',
      endDate: data['endDate'] ?? '-',
      dueDate: data['dueDate'] ?? '-',
    );
  }

  // Метод для конвертации в Map (для сохранения в Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'dueDate': dueDate,
    };
  }
}
