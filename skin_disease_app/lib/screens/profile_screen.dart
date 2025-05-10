import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/widgets/custom_button.dart';
import 'package:skin_disease_app/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Access the userModel directly from the provider
    if (authService.userModel != null) {
      setState(() {
        _nameController.text = authService.userModel!.name;
        _phoneController.text = authService.userModel!.phoneNumber;
        _profileImageUrl = authService.userModel!.profileImageUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return _profileImageUrl;

    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.user == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${authService.user!.uid}.jpg');

      final uploadTask = storageRef.putFile(_profileImage!);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Upload profile image if changed
    String? imageUrl = await _uploadProfileImage();

    // Update profile using the new method
    final success = await authService.updateUserProfile(
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      profileImageUrl: imageUrl,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
      setState(() {
        _isEditing = false;
        _profileImageUrl = imageUrl;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userModel = authService.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: authService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userModel == null
              ? const Center(child: Text('User not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image
                        GestureDetector(
                          onTap: _isEditing ? _pickImage : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : _profileImageUrl != null
                                        ? NetworkImage(_profileImageUrl!)
                                        : null,
                                child: (_profileImage == null && _profileImageUrl == null)
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email (non-editable)
                        Text(
                          userModel.email,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Name
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Name',
                          hintText: 'Enter your name',
                          prefixIcon: Icons.person_outline,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        CustomTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Account Actions
                        if (!_isEditing) ...[
                          // Medical History
                          ListTile(
                            leading: const Icon(Icons.history),
                            title: const Text('Medical History'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/medical_history');
                            },
                          ),

                          // Saved Articles
                          ListTile(
                            leading: const Icon(Icons.bookmark),
                            title: const Text('Saved Articles'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/saved_articles');
                            },
                          ),

                          // My Appointments
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('My Appointments'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/appointments');
                            },
                          ),

                          // Settings
                          ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text('Settings'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                          ),

                          // Sign Out
                          CustomButton(
                            text: 'Sign Out',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Sign Out'),
                                  content: const Text('Are you sure you want to sign out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Sign Out'),
                                    ),
                                  ],
                                ),
                              ) ?? false;

                              if (confirmed) {
                                await authService.signOut();
                              }
                            },
                            backgroundColor: Colors.red,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
