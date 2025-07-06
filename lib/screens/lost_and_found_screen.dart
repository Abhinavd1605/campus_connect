import 'dart:ui';
import 'package:campus_connect/models/found_item.dart';
import 'package:campus_connect/models/lost_item.dart';
import 'package:campus_connect/screens/lost_and_found/item_detail_screen.dart';
import 'package:campus_connect/screens/lost_and_found/report_found_item_screen.dart';
import 'package:campus_connect/screens/lost_and_found/report_lost_item_screen.dart';
import 'package:campus_connect/services/database_service.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:campus_connect/utils/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String? _selectedCategory;
  String? _selectedStatus;
  bool _showOnlyMyItems = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchTerm = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppStyles.backgroundLight,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text('Lost & Found', style: AppStyles.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: AppStyles.primaryColor),
                    onPressed: () => _showFilterDialog(),
                  ),
                ],
                bottom: const TabBar(
                  indicatorColor: AppStyles.primaryColor,
                  labelColor: AppStyles.primaryColor,
                  unselectedLabelColor: AppStyles.textMedium,
                  tabs: [
                    Tab(text: 'Lost Items'),
                    Tab(text: 'Found Items'),
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: [
              // Enhanced Search Bar
              Container(
                margin: const EdgeInsets.fromLTRB(AppStyles.paddingLarge, AppStyles.paddingLarge, AppStyles.paddingLarge, AppStyles.marginSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: AppStyles.glassmorphismBoxDecoration(context).copyWith(
                        color: AppStyles.surfaceLight.withOpacity(0.9),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by item name, description, or location...',
                          prefixIcon: const Icon(Icons.search, color: AppStyles.primaryColor),
                          suffixIcon: _searchTerm.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppStyles.textMedium),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchTerm = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(vertical: AppStyles.paddingMedium),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Active Filters Display
              if (_selectedCategory != null || _selectedStatus != null || _showOnlyMyItems)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppStyles.paddingLarge),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_selectedCategory != null)
                        _buildFilterChip('Category: $_selectedCategory', () {
                          setState(() {
                            _selectedCategory = null;
                          });
                        }),
                      if (_selectedStatus != null)
                        _buildFilterChip('Status: $_selectedStatus', () {
                          setState(() {
                            _selectedStatus = null;
                          });
                        }),
                      if (_showOnlyMyItems)
                        _buildFilterChip('My Items Only', () {
                          setState(() {
                            _showOnlyMyItems = false;
                          });
                        }),
                    ],
                  ),
                ),
              
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLostItemsList(),
                    _buildFoundItemsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: 'report_lost_fab',
              backgroundColor: AppStyles.primaryColor,
              onPressed: () => Navigator.of(context).push(
                CustomPageRoute(child: const ReportLostItemScreen()),
              ),
              label: const Text('Report Lost'),
              icon: const Icon(Icons.add),
            ),
            const SizedBox(height: AppStyles.marginMedium),
            FloatingActionButton.extended(
              heroTag: 'report_found_fab',
              backgroundColor: AppStyles.accentColor,
              onPressed: () => Navigator.of(context).push(
                CustomPageRoute(child: const ReportFoundItemScreen()),
              ),
              label: const Text('Report Found'),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
      deleteIconColor: AppStyles.primaryColor,
    );
  }

  // Helper method to build the list of lost items
  Widget _buildLostItemsList() {
    return StreamBuilder<List<LostItem>>(
      stream: _databaseService.getLostItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppStyles.accentColor));
        }
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppStyles.textMedium),
                const SizedBox(height: AppStyles.marginMedium),
                Text('An error occurred', style: AppStyles.textTheme.titleMedium),
                const SizedBox(height: AppStyles.marginSmall),
                Text('Please try again later', style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium)),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppStyles.textMedium),
                const SizedBox(height: AppStyles.marginMedium),
                Text('No lost items reported yet', style: AppStyles.textTheme.titleMedium),
                const SizedBox(height: AppStyles.marginSmall),
                Text('Be the first to report a lost item!', style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium)),
              ],
            ),
          );
        }

        // Enhanced filtering logic
        var items = snapshot.data!;
        
        // Search filter
        if (_searchTerm.isNotEmpty) {
          items = items.where((item) =>
              item.itemName.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              item.description.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              item.location.toLowerCase().contains(_searchTerm.toLowerCase())
          ).toList();
        }
        
        // Category filter
        if (_selectedCategory != null) {
          items = items.where((item) => item.category == _selectedCategory).toList();
        }
        
        // Status filter
        if (_selectedStatus != null) {
          items = items.where((item) => item.status == _selectedStatus).toList();
        }
        
        // My items filter
        if (_showOnlyMyItems) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            items = items.where((item) => item.userId == currentUser.uid).toList();
          }
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_list_off, size: 64, color: AppStyles.textMedium),
                const SizedBox(height: AppStyles.marginMedium),
                Text('No items match your filters', style: AppStyles.textTheme.titleMedium),
                const SizedBox(height: AppStyles.marginSmall),
                Text('Try adjusting your search criteria', style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium)),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          padding: const EdgeInsets.all(8),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildItemCard(items[index]);
          },
        );
      },
    );
  }

  // Helper method to build the list of found items
  Widget _buildFoundItemsList() {
    return StreamBuilder<List<FoundItem>>(
      stream: _databaseService.getFoundItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppStyles.accentColor));
        }
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppStyles.textMedium),
                const SizedBox(height: AppStyles.marginMedium),
                Text('An error occurred', style: AppStyles.textTheme.titleMedium),
                const SizedBox(height: AppStyles.marginSmall),
                Text('Please try again later', style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium)),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.find_in_page, size: 64, color: AppStyles.textMedium),
                const SizedBox(height: AppStyles.marginMedium),
                Text('No found items reported yet', style: AppStyles.textTheme.titleMedium),
                const SizedBox(height: AppStyles.marginSmall),
                Text('Be the first to report a found item!', style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium)),
              ],
            ),
          );
        }

        // Enhanced filtering logic
        var items = snapshot.data!;
        
        // Search filter
        if (_searchTerm.isNotEmpty) {
          items = items.where((item) =>
              item.itemName.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              item.description.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              item.location.toLowerCase().contains(_searchTerm.toLowerCase())
          ).toList();
        }
        
        // Category filter
        if (_selectedCategory != null) {
          items = items.where((item) => item.category == _selectedCategory).toList();
        }
        
        // Status filter
        if (_selectedStatus != null) {
          items = items.where((item) => item.status == _selectedStatus).toList();
        }
        
        // My items filter
        if (_showOnlyMyItems) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            items = items.where((item) => item.userId == currentUser.uid).toList();
          }
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_list_off, size: 64, color: AppStyles.textMedium),
                const SizedBox(height: AppStyles.marginMedium),
                Text('No items match your filters', style: AppStyles.textTheme.titleMedium),
                const SizedBox(height: AppStyles.marginSmall),
                Text('Try adjusting your search criteria', style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium)),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          padding: const EdgeInsets.all(8),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildItemCard(items[index]);
          },
        );
      },
    );
  }

  // Enhanced item card with status indicator
  Widget _buildItemCard(dynamic item) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(CustomPageRoute(
        child: ItemDetailScreen(item: item),
      )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.all(AppStyles.marginSmall),
            decoration: AppStyles.glassmorphismBoxDecoration(context).copyWith(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    (item.imageUrls != null && item.imageUrls.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppStyles.borderRadiusLarge),
                              topRight: Radius.circular(AppStyles.borderRadiusLarge),
                            ),
                            child: Image.network(
                              item.imageUrls.first,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppStyles.primaryColor.withOpacity(0.08),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppStyles.borderRadiusLarge),
                                topRight: Radius.circular(AppStyles.borderRadiusLarge),
                              ),
                            ),
                            child: Icon(Icons.image, size: 50, color: AppStyles.primaryColor.withOpacity(0.4)),
                          ),
                    // Status badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppStyles.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: AppStyles.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppStyles.marginSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppStyles.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.category,
                          style: AppStyles.textTheme.bodySmall?.copyWith(
                            color: AppStyles.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppStyles.marginSmall),
                      Text(
                        item.description,
                        style: AppStyles.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppStyles.marginSmall),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: AppStyles.accentColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: AppStyles.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  // Enhanced filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.filter_list, color: AppStyles.primaryColor),
              const SizedBox(width: AppStyles.marginSmall),
              const Text('Filter Items'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                             // Category filter
               DropdownButtonFormField<String?>(
                 value: _selectedCategory,
                 decoration: const InputDecoration(
                   labelText: 'Category',
                   border: OutlineInputBorder(),
                 ),
                 items: [
                   const DropdownMenuItem<String?>(value: null, child: Text('All Categories')),
                   const DropdownMenuItem<String?>(value: 'Electronics', child: Text('Electronics')),
                   const DropdownMenuItem<String?>(value: 'Books', child: Text('Books')),
                   const DropdownMenuItem<String?>(value: 'Clothing', child: Text('Clothing')),
                   const DropdownMenuItem<String?>(value: 'Accessories', child: Text('Accessories')),
                   const DropdownMenuItem<String?>(value: 'Documents', child: Text('Documents')),
                   const DropdownMenuItem<String?>(value: 'Sports Equipment', child: Text('Sports Equipment')),
                   const DropdownMenuItem<String?>(value: 'Other', child: Text('Other')),
                 ],
                 onChanged: (value) {
                   setState(() {
                     _selectedCategory = value;
                   });
                 },
               ),
              const SizedBox(height: AppStyles.marginMedium),
              
                             // Status filter
               DropdownButtonFormField<String?>(
                 value: _selectedStatus,
                 decoration: const InputDecoration(
                   labelText: 'Status',
                   border: OutlineInputBorder(),
                 ),
                 items: [
                   const DropdownMenuItem<String?>(value: null, child: Text('All Statuses')),
                   const DropdownMenuItem<String?>(value: 'lost', child: Text('LOST')),
                   const DropdownMenuItem<String?>(value: 'found', child: Text('FOUND')),
                   const DropdownMenuItem<String?>(value: 'claimed', child: Text('CLAIMED')),
                   const DropdownMenuItem<String?>(value: 'returned', child: Text('RETURNED')),
                 ],
                 onChanged: (value) {
                   setState(() {
                     _selectedStatus = value;
                   });
                 },
               ),
              const SizedBox(height: AppStyles.marginMedium),
              
              // My items only checkbox
              CheckboxListTile(
                title: const Text('Show only my items'),
                value: _showOnlyMyItems,
                onChanged: (value) {
                  setState(() {
                    _showOnlyMyItems = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _selectedStatus = null;
                  _showOnlyMyItems = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Clear All'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
} 