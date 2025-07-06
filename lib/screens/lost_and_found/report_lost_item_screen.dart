import 'dart:io';

import 'package:campus_connect/services/database_service.dart';
import 'package:campus_connect/services/storage_service.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportLostItemScreen extends StatefulWidget {
  const ReportLostItemScreen({super.key});

  @override
  State<ReportLostItemScreen> createState() => _ReportLostItemScreenState();
}

class _ReportLostItemScreenState extends State<ReportLostItemScreen> {
  final PageController _pageController = PageController();
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
  int _currentPage = 0;
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _rewardController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDateTime;
  bool _isLoading = false;
  XFile? _image;
  String _contactPreference = 'anonymous';

  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Electronics',
    'Books',
    'Clothing',
    'Accessories',
    'Documents',
    'Sports Equipment',
    'Other'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _reportLostItem() async {
    if (_formKeys[_currentPage].currentState!.validate() && _selectedDateTime != null && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle user not logged in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _storageService.uploadImage(_image!);
        if (imageUrl == null) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed. Please try again.')),
          );
          return;
        }
      }

      final lostItemData = {
        'itemName': _itemNameController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'location': _locationController.text,
        'lostDateTime': Timestamp.fromDate(_selectedDateTime!),
        'imageUrls': imageUrl != null ? [imageUrl] : [],
        'contactPreference': _contactPreference,
        'rewardAmount': double.tryParse(_rewardController.text),
        'userId': user.uid,
        'postedDate': Timestamp.now(),
        'status': 'lost',
      };

      await _databaseService.addLostItem(lostItemData);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lost item reported successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime =
              DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Report Lost Item', style: AppStyles.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppStyles.primaryColor),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppStyles.marginLarge),
          AppStyles.logoWithBackground(width: 60, height: 60),
          const SizedBox(height: AppStyles.marginLarge),
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingLarge, vertical: AppStyles.marginMedium),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 6.0,
              decoration: BoxDecoration(
                color: _currentPage >= index ? AppStyles.primaryColor : AppStyles.textLight,
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.paddingLarge),
      child: Form(
        key: _formKeys[0],
        child: SingleChildScrollView(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge)),
            color: AppStyles.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.search_off, color: AppStyles.primaryColor),
                      const SizedBox(width: AppStyles.marginSmall),
                      Text('Lost Item Details', style: AppStyles.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppStyles.marginLarge),
                  TextFormField(
                    controller: _itemNameController,
                    decoration: _buildInputDecoration('Item Name', Icons.label),
                    validator: (value) => value!.isEmpty ? 'Please enter the item name' : null,
                  ),
                  const SizedBox(height: AppStyles.marginMedium),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _buildInputDecoration('Description', Icons.description),
                    validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: AppStyles.marginMedium),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: _buildInputDecoration('Category', Icons.category),
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: AppStyles.marginLarge),
                  _isLoading
                      ? const CircularProgressIndicator(color: AppStyles.primaryColor)
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            child: const Text('Next'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.paddingLarge),
      child: Form(
        key: _formKeys[1],
        child: SingleChildScrollView(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge)),
            color: AppStyles.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppStyles.primaryColor),
                      const SizedBox(width: AppStyles.marginSmall),
                      Text('Location & Date', style: AppStyles.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppStyles.marginLarge),
                  TextFormField(
                    controller: _locationController,
                    decoration: _buildInputDecoration('Location Lost', Icons.location_on),
                    validator: (value) => value!.isEmpty ? 'Please enter the location' : null,
                  ),
                  const SizedBox(height: AppStyles.marginMedium),
                  ListTile(
                    title: Text(_selectedDateTime == null
                        ? 'Select Date and Time'
                        : 'Lost on: ${_selectedDateTime.toString()}'),
                    trailing: const Icon(Icons.calendar_today, color: AppStyles.primaryColor),
                    onTap: () => _selectDateTime(context),
                  ),
                  const SizedBox(height: AppStyles.marginMedium),
                  TextFormField(
                    controller: _rewardController,
                    decoration: _buildInputDecoration('Reward (Optional)', Icons.monetization_on),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppStyles.marginLarge),
                  _isLoading
                      ? const CircularProgressIndicator(color: AppStyles.primaryColor)
                      : Row(
                          children: [
                            if (_currentPage > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _previousPage,
                                  child: const Text('Back'),
                                ),
                              ),
                            if (_currentPage > 0) const SizedBox(width: AppStyles.marginMedium),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _nextPage,
                                child: const Text('Next'),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.paddingLarge),
      child: Form(
        key: _formKeys[2],
        child: SingleChildScrollView(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge)),
            color: AppStyles.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.image, color: AppStyles.primaryColor),
                      const SizedBox(width: AppStyles.marginSmall),
                      Text('Upload Image & Contact', style: AppStyles.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppStyles.marginLarge),
                  GestureDetector(
                    onTap: _pickImage,
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
                            child: Image.file(
                              File(_image!.path),
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: AppStyles.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
                            ),
                            child: Icon(Icons.add_a_photo, size: 40, color: AppStyles.primaryColor.withOpacity(0.5)),
                          ),
                  ),
                  const SizedBox(height: AppStyles.marginLarge),
                  DropdownButtonFormField<String>(
                    value: _contactPreference,
                    decoration: _buildInputDecoration('Contact Preference', Icons.contact_mail),
                    items: [
                      DropdownMenuItem(value: 'anonymous', child: Text('Anonymous')),
                      DropdownMenuItem(value: 'email', child: Text('Email')),
                      DropdownMenuItem(value: 'phone', child: Text('Phone')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _contactPreference = value!;
                      });
                    },
                  ),
                  const SizedBox(height: AppStyles.marginLarge),
                  _isLoading
                      ? const CircularProgressIndicator(color: AppStyles.primaryColor)
                      : Row(
                          children: [
                            if (_currentPage > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _previousPage,
                                  child: const Text('Back'),
                                ),
                              ),
                            if (_currentPage > 0) const SizedBox(width: AppStyles.marginMedium),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _reportLostItem,
                                child: const Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, [IconData? icon]) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppStyles.primaryColor) : null,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 