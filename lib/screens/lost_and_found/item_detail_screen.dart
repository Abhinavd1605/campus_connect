import 'package:campus_connect/models/found_item.dart';
import 'package:campus_connect/models/lost_item.dart';
import 'package:campus_connect/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campus_connect/utils/app_styles.dart';

class ItemDetailScreen extends StatefulWidget {
  final Object item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<dynamic> _potentialMatches = [];
  bool _isLoadingMatches = false;

  @override
  void initState() {
    super.initState();
    _loadPotentialMatches();
  }

  Future<void> _loadPotentialMatches() async {
    setState(() {
      _isLoadingMatches = true;
    });

    try {
      if (widget.item is LostItem) {
        final matches = await _databaseService.findPotentialMatches(widget.item as LostItem);
        setState(() {
          _potentialMatches = matches;
        });
      } else if (widget.item is FoundItem) {
        final matches = await _databaseService.findPotentialMatchesForFound(widget.item as FoundItem);
        setState(() {
          _potentialMatches = matches;
        });
      }
    } catch (e) {
      print('Error loading potential matches: $e');
    } finally {
      setState(() {
        _isLoadingMatches = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLostItem = widget.item is LostItem;
    final dynamic typedItem = widget.item;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final bool isOwner =
        currentUser != null && currentUser.uid == typedItem.userId;

    return Scaffold(
      backgroundColor: AppStyles.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isLostItem ? 'Lost Item Details' : 'Found Item Details', 
          style: AppStyles.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppStyles.primaryColor),
        actions: [
          if (!isOwner)
            IconButton(
              icon: const Icon(Icons.share, color: AppStyles.primaryColor),
              onPressed: () => _showShareDialog(context, typedItem),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppStyles.logoWithBackground(width: 70, height: 70),
            const SizedBox(height: AppStyles.marginLarge),
            
            // Main Item Card
            _buildMainItemCard(typedItem, isLostItem, isOwner),
            
            const SizedBox(height: AppStyles.marginLarge),
            
            // Potential Matches Section
            if (_potentialMatches.isNotEmpty)
              _buildPotentialMatchesSection(isLostItem),
            
            const SizedBox(height: AppStyles.marginLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildMainItemCard(dynamic typedItem, bool isLostItem, bool isOwner) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
      ),
      color: AppStyles.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(typedItem.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                typedItem.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: AppStyles.marginMedium),
            
            // Image
            typedItem.imageUrls.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
                    child: Image.network(
                      typedItem.imageUrls.first,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppStyles.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
                    ),
                    child: Icon(Icons.image, size: 80, color: AppStyles.primaryColor.withOpacity(0.4)),
                  ),
            
            const SizedBox(height: AppStyles.marginLarge),
            
            // Item Name
            Row(
              children: [
                Icon(isLostItem ? Icons.search_off : Icons.find_in_page, color: AppStyles.primaryColor),
                const SizedBox(width: AppStyles.marginSmall),
                Expanded(
                  child: Text(
                    typedItem.itemName,
                    style: AppStyles.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppStyles.marginMedium),
            
            // Details
            _buildDetailRow(Icons.description, 'Description', typedItem.description),
            _buildDetailRow(Icons.category, 'Category', typedItem.category),
            _buildDetailRow(Icons.location_on, isLostItem ? 'Lost Location' : 'Found Location', typedItem.location),
            _buildDetailRow(Icons.calendar_today, isLostItem ? 'Lost Date' : 'Found Date',
              DateFormat.yMd().add_jm().format(isLostItem ? typedItem.lostDateTime : typedItem.foundDateTime)),
            
            if (isLostItem && typedItem.rewardAmount != null)
              _buildDetailRow(Icons.monetization_on, 'Reward', '\$${typedItem.rewardAmount}'),
            
            if (!isLostItem)
              _buildDetailRow(Icons.place, 'Current Location', typedItem.currentItemLocation),
            
            if (!isLostItem && (typedItem.reporterContactEmail != null && typedItem.reporterContactEmail.isNotEmpty))
              _buildDetailRow(Icons.email, 'Reporter Email', typedItem.reporterContactEmail),
            
            if (!isLostItem && (typedItem.reporterContactPhone != null && typedItem.reporterContactPhone.isNotEmpty))
              _buildDetailRow(Icons.phone, 'Reporter Phone', typedItem.reporterContactPhone),
            
            const SizedBox(height: AppStyles.marginLarge),
            
            // Action Buttons
            _buildActionButtons(typedItem, isLostItem, isOwner),
          ],
        ),
      ),
    );
  }

  Widget _buildPotentialMatchesSection(bool isLostItem) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
      ),
      color: AppStyles.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppStyles.accentColor),
                const SizedBox(width: AppStyles.marginSmall),
                Text(
                  'Potential Matches',
                  style: AppStyles.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.marginMedium),
            Text(
              'We found some ${isLostItem ? 'found' : 'lost'} items that might match:',
              style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium),
            ),
            const SizedBox(height: AppStyles.marginMedium),
            if (_isLoadingMatches)
              const Center(child: CircularProgressIndicator(color: AppStyles.accentColor))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _potentialMatches.length,
                itemBuilder: (context, index) {
                  final match = _potentialMatches[index];
                  return _buildMatchCard(match, isLostItem);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(dynamic match, bool isLostItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.marginSmall),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppStyles.accentColor.withOpacity(0.1),
          child: Icon(
            isLostItem ? Icons.find_in_page : Icons.search_off,
            color: AppStyles.accentColor,
          ),
        ),
        title: Text(
          match.itemName,
          style: AppStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(match.category),
            Text(
              isLostItem ? 'Found at: ${match.location}' : 'Lost at: ${match.location}',
              style: AppStyles.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: AppStyles.accentColor),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(item: match),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(dynamic typedItem, bool isLostItem, bool isOwner) {
    if (isOwner) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(isLostItem ? Icons.check_circle : Icons.assignment_turned_in),
          onPressed: () async {
            final newStatus = isLostItem ? 'claimed' : 'returned';
            if (isLostItem) {
              await _databaseService.updateLostItemStatus(typedItem.id, newStatus);
            } else {
              await _databaseService.updateFoundItemStatus(typedItem.id, newStatus);
            }
            Navigator.of(context).pop();
          },
          label: Text(isLostItem ? 'Mark as Claimed' : 'Mark as Returned'),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.contact_mail),
          onPressed: () async {
            final ownerData = await _databaseService.getUserData(typedItem.userId);
            final owner = ownerData.data() as Map<String, dynamic>;
            final contactPreference = owner['contactPreference'];
            if (contactPreference == 'email') {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: owner['email'],
                query: 'subject=${isLostItem ? 'Lost' : 'Found'} Item: ${typedItem.itemName}',
              );
              launchUrl(emailLaunchUri);
            } else if (contactPreference == 'phone') {
              final Uri phoneLaunchUri = Uri(
                scheme: 'tel',
                path: owner['phone'],
              );
              launchUrl(phoneLaunchUri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('The user has chosen to remain anonymous.')),
              );
            }
          },
          label: const Text('Contact Owner'),
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'lost':
        return Colors.orange;
      case 'found':
        return Colors.green;
      case 'claimed':
      case 'returned':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showShareDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Item'),
        content: const Text('Share this item with others to help find it faster!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement sharing functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing feature coming soon!')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.marginSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppStyles.primaryColor, size: 22),
          const SizedBox(width: AppStyles.marginSmall),
          Text('$title: ', style: AppStyles.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: AppStyles.textTheme.bodyMedium)),
        ],
      ),
    );
  }
} 