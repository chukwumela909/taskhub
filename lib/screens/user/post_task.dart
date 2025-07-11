import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/location_provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/services/image_service.dart';
import 'package:taskhub/services/location_service.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/widgets/location_services_dialog.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class PostTaskScreen extends StatefulWidget {
  const PostTaskScreen({super.key});

  @override
  State<PostTaskScreen> createState() => _PostTaskScreenState();
}

class _PostTaskScreenState extends State<PostTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImageService _imageService = ImageService();
  final LocationService _locationService = LocationService();

  List<Map<String, dynamic>> _selectedCategories = [];

  bool _bargainEnabled = false;
  bool _imagesEnabled = true;
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedDeadline;
  bool _isSubmitting = false;
  bool _isUploadingImages = false;
  
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    // Check location and fetch categories when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationServices();
      _fetchCategories();
    });
  }

  // Fetch categories from API
  Future<void> _fetchCategories() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _paymentController.dispose();
    _deadlineController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Check if location services are enabled
  Future<void> _checkLocationServices() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.initLocation();
    
    // If location is disabled, show dialog
    if (locationProvider.isLocationServiceDisabled && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LocationServicesDialog(
          onLocationEnabled: () {
            // This will be called after the user returns from location settings
          },
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      print('Error picking images: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting images. Please check app permissions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _openCategorySelection() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final categories = taskProvider.categories;
            final isLoading = taskProvider.categoriesStatus == TaskStatus.loading;
            final hasError = taskProvider.categoriesStatus == TaskStatus.error;
            
            return StatefulBuilder(
              builder: (context, setDialogState) {
                String searchQuery = '';
                List<Map<String, dynamic>> filteredCategories = categories.where((category) {
                  final name = (category['displayName'] ?? category['name'] ?? '').toLowerCase();
                  return name.contains(searchQuery.toLowerCase());
                }).toList();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fixed header
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Geist',
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                const Text(
                                'Select up to 5 categories for better matches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Geist',
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                                  onChanged: (value) {
                                    setDialogState(() {
                                      searchQuery = value;
                                    });
                                  },
                    decoration: const InputDecoration(
                      hintText: 'Search Category',
                      hintStyle: TextStyle(
                        color: Color(0xFFBBBBBB),
                        fontSize: 16,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Suggested label
                const Text(
                  'Suggested',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Geist',
                    color: Color(0xFF333333),
                  ),
                ),
                            ],
                          ),
                        ),
                
                        // Flexible categories list
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : hasError
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Error loading categories',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontFamily: 'Geist',
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              taskProvider.fetchCategories();
                                            },
                                            child: Text('Retry'),
                                          ),
                                        ],
                                      )
                                    : filteredCategories.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No categories found',
                                              style: TextStyle(
                                                fontFamily: 'Geist',
                                                color: Color(0xFF666666),
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                    shrinkWrap: true,
                                            itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                                              final category = filteredCategories[index];
                                              final isSelected = _selectedCategories.any((cat) => cat['_id'] == category['_id']);
                                              
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                                        if (isSelected) {
                                                          _selectedCategories.removeWhere((cat) => cat['_id'] == category['_id']);
                                                        } else {
                                                          if (_selectedCategories.length < 5) {
                                                            _selectedCategories.add(category);
                                                          }
                                                        }
                                                      });
                                                      setDialogState(() {}); // Update dialog state
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                                          Expanded(
                                                            child: Text(
                                                              category['displayName'] ?? category['name'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Geist',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                                          ),
                                                          Checkbox(
                                                            value: isSelected,
                                                            onChanged: (bool? value) {
                                                              setState(() {
                                                                if (isSelected) {
                                                                  _selectedCategories.removeWhere((cat) => cat['_id'] == category['_id']);
                                                                } else {
                                                                  if (_selectedCategories.length < 5) {
                                                                    _selectedCategories.add(category);
                                                                  }
                                                                }
                                                              });
                                                              setDialogState(() {}); // Update dialog state
                                                            },
                                                            activeColor: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                                                  if (index < filteredCategories.length - 1)
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ],
                      );
                    },
                                          ),
                          ),
                        ),
                        
                        // Fixed footer
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Done (${_selectedCategories.length}/5)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Geist',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Add tag to the list
  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  // Remove a tag from the list
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitTask() async {
    if (_validateInputs()) {
      setState(() {
        _isSubmitting = true;
      });

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      try {
        // Parse payment amount
        double budget = double.tryParse(_paymentController.text.trim()) ?? 0.0;
        
        // Prepare and upload images if enabled
        List<Map<String, String>>? images;
        
        if (_imagesEnabled && _selectedImages.isNotEmpty) {
          setState(() {
            _isUploadingImages = true;
          });
          
          try {
            // Convert XFiles to Files for uploading
            final files = await _imageService.xFilesToFiles(_selectedImages);
            
            // Upload images to Cloudinary
            final imageUrls = await _imageService.uploadImages(files);
            
            // Format images for API
            images = imageUrls.map((url) => {
              "url": url
            }).toList();
            
            print('Images prepared for API: $images');
          } catch (e) {
            print('Error uploading images: $e');
            _showValidationError('Error uploading images. Please try again.');
            setState(() {
              _isSubmitting = false;
              _isUploadingImages = false;
            });
            return;
          } finally {
            setState(() {
              _isUploadingImages = false;
            });
          }
        }

        // Get precise location data
        Position? currentPosition;
        try {
          // Try to get the most current position
          currentPosition = await _locationService.getCurrentPosition();
        } catch (e) {
          print('Error getting current position: $e');
          // We'll fall back to saved position if needed
        }

        // If we couldn't get a current position, try to use the one from the provider
        if (currentPosition == null && locationProvider.hasLocation) {
          currentPosition = locationProvider.currentPosition;
        }

        // Prepare location data for API
        Map<String, dynamic> location;
        
        if (currentPosition != null) {
          location = {
            "latitude": currentPosition.latitude,
            "longitude": currentPosition.longitude
          };
        } else {
          // Fallback to placeholder location if really needed
          location = {
            "latitude": 37.7749, // Default San Francisco coordinates
            "longitude": -122.4194
          };
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Using placeholder location. Enable location for better accuracy.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }

        // Prepare tags
        List<String> tags = _tags.isNotEmpty ? _tags : ['general'];

        // Submit task using provider
        final success = await taskProvider.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categories: _selectedCategories.map((cat) => cat['_id'] as String).toList(),
          budget: budget,
          deadline: _selectedDeadline!,
          isBiddingEnabled: _bargainEnabled,
          tags: tags,  
          images: images,
          location: location,
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          _showValidationError(taskProvider.errorMessage ?? 'Failed to post task');
        }
      } catch (e) {
        _showValidationError('Error: ${e.toString()}');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),

              Container(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 0, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section with Post button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Post task title
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Post task',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 24,
                                fontFamily: 'Geist',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a task of your choice and\npost for taskers to be up to the task',
                              style: TextStyle(
                                color: const Color(0xFF606060).withOpacity(0.7),
                                fontSize: 14,
                                fontFamily: 'Geist',
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),

                        // Post button
                        Container(
                          child: ElevatedButton(
                            onPressed: _isSubmitting 
                                ? null  // Disable button when submitting
                                : _submitTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSubmitting 
                                  ? Colors.grey.shade300
                                  : const Color(0xFFE8E8E8),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSubmitting
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            primaryColor,
                                          ),
                                        ),
                                      ),
                                      
                                  
                                    ],
                                  )
                                : Text(
                                    'Post',
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 16,
                                      fontFamily: 'Geist',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Center(
                      child: Container(
                        height: 1,
                        width: 180,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                  ],
                ),
              ),

              // Form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Title
                    const Text(
                      'Task Title',
                      style: TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 16,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'e.g Interior Decoration',
                          hintStyle: TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 16,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Task Categories
                    const Text(
                      'Task Categories',
                      style: TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 16,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _openCategorySelection,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _selectedCategories.isEmpty
                                  ? Text(
                                      'Select Categories (Max 5)',
                              style: TextStyle(
                                        color: const Color(0xFFBBBBBB),
                                fontSize: 16,
                                fontFamily: 'Geist',
                                fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: _selectedCategories.map((category) {
                                        return Chip(
                                          label: Text(
                                            category['displayName'] ?? category['name'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Geist',
                                            ),
                                          ),
                                          backgroundColor: primaryColor.withOpacity(0.1),
                                          labelStyle: TextStyle(color: primaryColor),
                                          deleteIcon: Icon(Icons.close, size: 16),
                                          onDeleted: () {
                                            setState(() {
                                              _selectedCategories.removeWhere((cat) => cat['_id'] == category['_id']);
                                            });
                                          },
                                        );
                                      }).toList(),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF606060),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Offer and Bargain
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                children: [
                                  const Text(
                                        'Payment Offer (',
                                    style: TextStyle(
                                      color: Color(0xFF606060),
                                      fontSize: 16,
                                      fontFamily: 'Geist',
                                      fontWeight: FontWeight.w500,
                                    ),
                                      ),
                                      const Text(
                                        '₦',
                                        style: TextStyle(
                                          color: Color(0xFF606060),
                                          fontSize: 16,
                                          fontFamily: 'Arial',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Text(
                                        ')',
                                        style: TextStyle(
                                          color: Color(0xFF606060),
                                          fontSize: 16,
                                          fontFamily: 'Geist',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Bargain',
                                        style: TextStyle(
                                          color: Color(0xFF606060),
                                          fontSize: 16,
                                          fontFamily: 'Geist',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                          value: _bargainEnabled,
                                          onChanged: (value) => setState(
                                              () => _bargainEnabled = value),
                                          activeColor: primaryColor,
                                          activeTrackColor: primaryColor.withOpacity(0.1),
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor:
                                              Colors.grey.shade300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextField(
                                  controller: _paymentController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g 400.00',
                                    hintStyle: TextStyle(
                                      color: Color(0xFFBBBBBB),
                                      fontSize: 16,
                                      fontFamily: 'Geist',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Deadline
                    const Text(
                      'Deadline ( End Date )',
                      style: TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 16,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        controller: _deadlineController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'DD - MM - YYYY',
                          hintStyle: const TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 16,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/calendar-icon.svg',
                              color: const Color(0xFF606060),
                              width: 20,
                              height: 20,
                            ),
                            onPressed: _selectDate,
                          ),
                          // suffix: SvgPicture.asset(
                          //   'assets/icons/calendar-icon.svg',
                          //   color: const Color(0xFF606060),
                          //   width: 16,
                          //   height: 16,
                          // ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Task Description
                    const Text(
                      'Task Description',
                      style: TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 16,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                              "Write a brief description about the task you're about posting...",
                          hintStyle: TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 16,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Task Images
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task Images Header with Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Task Images',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 18,
                                  fontFamily: 'Geist',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: _imagesEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _imagesEnabled = value;
                                    });
                                  },
                                  activeColor: primaryColor,
                                  activeTrackColor: primaryColor.withOpacity(0.1),
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                          
                          // Subtitle
                          Text(
                            'Upload task images to help find taskers faster',
                            style: TextStyle(
                              color: const Color(0xFF606060).withOpacity(0.9),
                              fontSize: 17,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Image Upload UI based on state
                          if (_imagesEnabled)
                            _selectedImages.isEmpty
                                ? GestureDetector(
                                    onTap: _pickImages,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: Colors.black.withOpacity(0.05),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Text(
                                        'Upload Files',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                          fontSize: 17,
                                          fontFamily: 'Geist',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: double.infinity,
                                    child: GridView.count(
                                      crossAxisCount: 4,
                                      shrinkWrap: true,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      physics: NeverScrollableScrollPhysics(),
                                      children: [
                                        ..._selectedImages.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final image = entry.value;
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: FileImage(File(image.path)),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        // Add button
                                        GestureDetector(
                                          onTap: _pickImages,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5F5F5),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.black.withOpacity(0.05),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Color(0xFF606060),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tags
                    _buildTagsSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    // Title validation
    if (_titleController.text.trim().isEmpty) {
      _showValidationError('Please enter a task title');
      return false;
    }
    
    // Category validation
    if (_selectedCategories.isEmpty) {
      _showValidationError('Please select at least one category');
      return false;
    }
    
    // Payment validation
    if (_paymentController.text.trim().isEmpty) {
      _showValidationError('Please enter a budget amount');
      return false;
    }
    
    final budget = double.tryParse(_paymentController.text.trim());
    if (budget == null || budget <= 0) {
      _showValidationError('Please enter a valid budget amount');
      return false;
    }
    
    // Deadline validation
    if (_selectedDeadline == null) {
      _showValidationError('Please select a deadline');
      return false;
    }
    
    if (_selectedDeadline!.isBefore(DateTime.now())) {
      _showValidationError('Deadline must be in the future');
      return false;
    }
    
    // Description validation
    if (_descriptionController.text.trim().isEmpty) {
      _showValidationError('Please enter a description');
      return false;
    }
    
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Add the tags section to the build method
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontFamily: 'Geist',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    hintText: 'Add tags (e.g., urgent, indoor)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addTag(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_tagsController.text.isNotEmpty) {
                  _addTag(_tagsController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => _removeTag(tag),
              backgroundColor: primaryColor.withOpacity(0.1),
              labelStyle: TextStyle(color: primaryColor),
              deleteIconColor: primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}
