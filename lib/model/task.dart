import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String title;
  final String description;
  final String dueDate;
  final String id;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.id,
  });

  // Factory method to create a Task object from Firestore data
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Task(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: data['dueDate'] ?? '',
      id: data['id'] ?? '',
    );
  }
}
