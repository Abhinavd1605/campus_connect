import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_connect/models/lost_item.dart';
import 'package:campus_connect/models/found_item.dart';
import 'package:campus_connect/models/issue.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _lostItemsCollection =
      FirebaseFirestore.instance.collection('lost_items');

  final CollectionReference _foundItemsCollection =
      FirebaseFirestore.instance.collection('found_items');

  final CollectionReference _issuesCollection =
      FirebaseFirestore.instance.collection('issues');

  // Add a lost item
  Future<void> addLostItem(Map<String, dynamic> itemData) async {
    try {
      await _lostItemsCollection.add(itemData);
    } catch (e) {
      print(e.toString());
    }
  }

  // Add a found item
  Future<void> addFoundItem(Map<String, dynamic> itemData) async {
    try {
      await _foundItemsCollection.add(itemData);
    } catch (e) {
      print(e.toString());
    }
  }

  // Add an issue
  Future<void> addIssue(Map<String, dynamic> issueData) async {
    try {
      await _issuesCollection.add(issueData);
    } catch (e) {
      print(e.toString());
    }
  }

  // Get stream of lost items
  Stream<List<LostItem>> getLostItems() {
    return _lostItemsCollection
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LostItem.fromFirestore(doc)).toList();
    });
  }

  // Get stream of found items
  Stream<List<FoundItem>> getFoundItems() {
    return _foundItemsCollection
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FoundItem.fromFirestore(doc)).toList();
    });
  }

  // Get stream of issues
  Stream<List<Issue>> getIssues() {
    return _issuesCollection
        .orderBy('reportedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Issue.fromFirestore(doc)).toList();
    });
  }

  // Get user data
  Future<DocumentSnapshot> getUserData(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  // Get total lost items count
  Future<int> getLostItemsCount() async {
    final snapshot = await _lostItemsCollection.get();
    return snapshot.docs.length;
  }

  // Get total found items count
  Future<int> getFoundItemsCount() async {
    final snapshot = await _foundItemsCollection.get();
    return snapshot.docs.length;
  }

  // Get user's reported items count
  Future<int> getMyReportedItemsCount(String uid) async {
    final lostSnapshot =
        await _lostItemsCollection.where('userId', isEqualTo: uid).get();
    final foundSnapshot =
        await _foundItemsCollection.where('userId', isEqualTo: uid).get();
    return lostSnapshot.docs.length + foundSnapshot.docs.length;
  }

  // Get stream of my lost items
  Stream<List<LostItem>> getMyLostItems(String uid) {
    return _lostItemsCollection
        .where('userId', isEqualTo: uid)
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LostItem.fromFirestore(doc)).toList();
    });
  }

  // Get stream of my found items
  Stream<List<FoundItem>> getMyFoundItems(String uid) {
    return _foundItemsCollection
        .where('userId', isEqualTo: uid)
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FoundItem.fromFirestore(doc)).toList();
    });
  }

  // Get stream of my issues
  Stream<List<Issue>> getMyIssues(String uid) {
    return _issuesCollection
        .where('reporterId', isEqualTo: uid)
        .orderBy('reportedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Issue.fromFirestore(doc)).toList();
    });
  }

  // Update lost item status
  Future<void> updateLostItemStatus(String id, String status) async {
    try {
      await _lostItemsCollection.doc(id).update({'status': status});
    } catch (e) {
      print(e.toString());
    }
  }

  // Update found item status
  Future<void> updateFoundItemStatus(String id, String status) async {
    try {
      await _foundItemsCollection.doc(id).update({'status': status});
    } catch (e) {
      print(e.toString());
    }
  }

  // Find potential matches for a lost item
  Future<List<FoundItem>> findPotentialMatches(LostItem lostItem) async {
    try {
      final snapshot = await _foundItemsCollection
          .where('status', isEqualTo: 'found')
          .where('category', isEqualTo: lostItem.category)
          .get();
      
      List<FoundItem> potentialMatches = [];
      
      for (var doc in snapshot.docs) {
        final foundItem = FoundItem.fromFirestore(doc);
        
        // Calculate similarity score
        double score = 0.0;
        
        // Name similarity (case-insensitive)
        String lostName = lostItem.itemName.toLowerCase();
        String foundName = foundItem.itemName.toLowerCase();
        
        if (lostName.contains(foundName) || foundName.contains(lostName)) {
          score += 0.4; // High score for name similarity
        } else if (_calculateStringSimilarity(lostName, foundName) > 0.7) {
          score += 0.3; // Medium score for similar names
        }
        
        // Location similarity
        String lostLocation = lostItem.location.toLowerCase();
        String foundLocation = foundItem.location.toLowerCase();
        
        if (lostLocation.contains(foundLocation) || foundLocation.contains(lostLocation)) {
          score += 0.3; // High score for location similarity
        } else if (_calculateStringSimilarity(lostLocation, foundLocation) > 0.6) {
          score += 0.2; // Medium score for similar locations
        }
        
        // Time proximity (found within 7 days of lost date)
        final daysDifference = foundItem.foundDateTime.difference(lostItem.lostDateTime).inDays.abs();
        if (daysDifference <= 7) {
          score += 0.2; // Bonus for time proximity
        }
        
        // Only include items with a reasonable match score
        if (score >= 0.3) {
          potentialMatches.add(foundItem);
        }
      }
      
      // Sort by score (highest first)
      potentialMatches.sort((a, b) {
        double scoreA = _calculateMatchScore(lostItem, a);
        double scoreB = _calculateMatchScore(lostItem, b);
        return scoreB.compareTo(scoreA);
      });
      
      return potentialMatches.take(5).toList(); // Return top 5 matches
    } catch (e) {
      print('Error finding potential matches: $e');
      return [];
    }
  }

  // Find potential matches for a found item
  Future<List<LostItem>> findPotentialMatchesForFound(FoundItem foundItem) async {
    try {
      final snapshot = await _lostItemsCollection
          .where('status', isEqualTo: 'lost')
          .where('category', isEqualTo: foundItem.category)
          .get();
      
      List<LostItem> potentialMatches = [];
      
      for (var doc in snapshot.docs) {
        final lostItem = LostItem.fromFirestore(doc);
        
        // Calculate similarity score
        double score = 0.0;
        
        // Name similarity (case-insensitive)
        String lostName = lostItem.itemName.toLowerCase();
        String foundName = foundItem.itemName.toLowerCase();
        
        if (lostName.contains(foundName) || foundName.contains(lostName)) {
          score += 0.4; // High score for name similarity
        } else if (_calculateStringSimilarity(lostName, foundName) > 0.7) {
          score += 0.3; // Medium score for similar names
        }
        
        // Location similarity
        String lostLocation = lostItem.location.toLowerCase();
        String foundLocation = foundItem.location.toLowerCase();
        
        if (lostLocation.contains(foundLocation) || foundLocation.contains(lostLocation)) {
          score += 0.3; // High score for location similarity
        } else if (_calculateStringSimilarity(lostLocation, foundLocation) > 0.6) {
          score += 0.2; // Medium score for similar locations
        }
        
        // Time proximity (lost within 7 days of found date)
        final daysDifference = foundItem.foundDateTime.difference(lostItem.lostDateTime).inDays.abs();
        if (daysDifference <= 7) {
          score += 0.2; // Bonus for time proximity
        }
        
        // Only include items with a reasonable match score
        if (score >= 0.3) {
          potentialMatches.add(lostItem);
        }
      }
      
      // Sort by score (highest first)
      potentialMatches.sort((a, b) {
        double scoreA = _calculateMatchScore(b, foundItem);
        double scoreB = _calculateMatchScore(a, foundItem);
        return scoreB.compareTo(scoreA);
      });
      
      return potentialMatches.take(5).toList(); // Return top 5 matches
    } catch (e) {
      print('Error finding potential matches: $e');
      return [];
    }
  }

  // Helper method to calculate string similarity using Levenshtein distance
  double _calculateStringSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    
    int distance = _levenshteinDistance(s1, s2);
    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distance / maxLength);
  }

  // Levenshtein distance calculation
  int _levenshteinDistance(String s1, String s2) {
    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  // Calculate match score between lost and found items
  double _calculateMatchScore(LostItem lostItem, FoundItem foundItem) {
    double score = 0.0;
    
    // Name similarity
    String lostName = lostItem.itemName.toLowerCase();
    String foundName = foundItem.itemName.toLowerCase();
    
    if (lostName.contains(foundName) || foundName.contains(lostName)) {
      score += 0.4;
    } else if (_calculateStringSimilarity(lostName, foundName) > 0.7) {
      score += 0.3;
    }
    
    // Location similarity
    String lostLocation = lostItem.location.toLowerCase();
    String foundLocation = foundItem.location.toLowerCase();
    
    if (lostLocation.contains(foundLocation) || foundLocation.contains(lostLocation)) {
      score += 0.3;
    } else if (_calculateStringSimilarity(lostLocation, foundLocation) > 0.6) {
      score += 0.2;
    }
    
    // Time proximity
    final daysDifference = foundItem.foundDateTime.difference(lostItem.lostDateTime).inDays.abs();
    if (daysDifference <= 7) {
      score += 0.2;
    }
    
    return score;
  }
} 