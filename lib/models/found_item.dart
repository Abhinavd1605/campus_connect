import 'package:cloud_firestore/cloud_firestore.dart';

class FoundItem {
  final String id;
  final String itemName;
  final String description;
  final String category;
  final String location;
  final DateTime foundDateTime;
  final List<String> imageUrls;
  final String currentItemLocation;
  final String userId;
  final Timestamp postedDate;
  final String status;
  final String? reporterContactEmail;
  final String? reporterContactPhone;

  FoundItem({
    required this.id,
    required this.itemName,
    required this.description,
    required this.category,
    required this.location,
    required this.foundDateTime,
    required this.imageUrls,
    required this.currentItemLocation,
    required this.userId,
    required this.postedDate,
    required this.status,
    this.reporterContactEmail,
    this.reporterContactPhone,
  });

  factory FoundItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FoundItem(
      id: doc.id,
      itemName: data['itemName'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      foundDateTime: (data['foundDateTime'] is Timestamp)
          ? (data['foundDateTime'] as Timestamp).toDate()
          : DateTime.now(),
      imageUrls: data['imageUrls'] is List
          ? List<String>.from(data['imageUrls'])
          : <String>[],
      currentItemLocation: data['currentItemLocation'] ?? '',
      userId: data['userId'] ?? '',
      postedDate: data['postedDate'] ?? Timestamp.now(),
      status: data['status'] ?? 'found',
      reporterContactEmail: data['reporterContactEmail'],
      reporterContactPhone: data['reporterContactPhone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'description': description,
      'category': category,
      'location': location,
      'foundDateTime': foundDateTime,
      'imageUrls': imageUrls,
      'currentItemLocation': currentItemLocation,
      'userId': userId,
      'postedDate': postedDate,
      'status': status,
      'reporterContactEmail': reporterContactEmail,
      'reporterContactPhone': reporterContactPhone,
    };
  }
} 