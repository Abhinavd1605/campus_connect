import 'package:cloud_firestore/cloud_firestore.dart';

class LostItem {
  final String id;
  final String itemName;
  final String description;
  final String category;
  final String location;
  final DateTime lostDateTime;
  final List<String> imageUrls;
  final String contactPreference;
  final double? rewardAmount;
  final String userId;
  final Timestamp postedDate;
  final String status;

  LostItem({
    required this.id,
    required this.itemName,
    required this.description,
    required this.category,
    required this.location,
    required this.lostDateTime,
    required this.imageUrls,
    required this.contactPreference,
    this.rewardAmount,
    required this.userId,
    required this.postedDate,
    required this.status,
  });

  factory LostItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return LostItem(
      id: doc.id,
      itemName: data['itemName'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      lostDateTime: (data['lostDateTime'] is Timestamp)
          ? (data['lostDateTime'] as Timestamp).toDate()
          : DateTime.now(),
      imageUrls: data['imageUrls'] is List
          ? List<String>.from(data['imageUrls'])
          : <String>[],
      contactPreference: data['contactPreference'] ?? 'anonymous',
      rewardAmount: (data['rewardAmount'] as num?)?.toDouble(),
      userId: data['userId'] ?? '',
      postedDate: data['postedDate'] ?? Timestamp.now(),
      status: data['status'] ?? 'lost',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'description': description,
      'category': category,
      'location': location,
      'lostDateTime': lostDateTime,
      'imageUrls': imageUrls,
      'contactPreference': contactPreference,
      'rewardAmount': rewardAmount,
      'userId': userId,
      'postedDate': postedDate,
      'status': status,
    };
  }
} 