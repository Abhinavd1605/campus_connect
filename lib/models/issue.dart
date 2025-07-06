import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String id;
  final String category;
  final String location;
  final String description;
  final String priority;
  final String? imageUrl;
  final String status;
  final Timestamp reportedDate;
  final String? reporterId; // Not truly anonymous, but can be hidden on the client

  Issue({
    required this.id,
    required this.category,
    required this.location,
    required this.description,
    required this.priority,
    this.imageUrl,
    required this.status,
    required this.reportedDate,
    this.reporterId,
  });

  factory Issue.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Issue(
      id: doc.id,
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      priority: data['priority'] ?? 'Low',
      imageUrl: data['imageUrl'],
      status: data['status'] ?? 'Reported',
      reportedDate: (data['reportedDate'] is Timestamp)
          ? data['reportedDate']
          : Timestamp.now(),
      reporterId: data['reporterId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'location': location,
      'description': description,
      'priority': priority,
      'imageUrl': imageUrl,
      'status': status,
      'reportedDate': reportedDate,
      'reporterId': reporterId,
    };
  }
} 