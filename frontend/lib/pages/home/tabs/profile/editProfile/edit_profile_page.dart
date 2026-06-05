import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/api/auth/api_user.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/input_box.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> profileData;
  final String token;

  const EditProfilePage({
    super.key,
    required this.profileData,
    required this.token,
  });

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _dobError;

  late String _photoProfile;
  File? _selectedImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.profileData;
    _nameController = TextEditingController(text: data['nama'] ?? '');
    _emailController = TextEditingController(text: data['email'] ?? '');
    _phoneController = TextEditingController(text: data['telp_no'] ?? '');
    _dobController = TextEditingController();

    _photoProfile = data['photo_profile'] ?? '';

    _loadLocalDob();
  }

  Future<void> _loadLocalDob() async {
    final email = widget.profileData['email'] ?? 'default_user';
    final prefs = await SharedPreferences.getInstance();
    final savedDob = prefs.getString('dob_$email');
    if (savedDob != null && mounted) {
      setState(() {
        _dobController.text = savedDob;
      });
    } else {
      _dobController.text = '12/27/2005'; // Default mockup Date of Birth
    }
  }

  Future<void> _saveLocalDob(String email, String dob) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dob_$email', dob);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Opens a beautiful modal bottom sheet to pick an image directly from phone gallery/camera
  Future<void> _editProfilePhoto() async {
    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.deepTeal, size: 24),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepTeal, fontSize: 15),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                    maxWidth: 600,
                    maxHeight: 600,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImageFile = File(pickedFile.path);
                      _photoProfile = pickedFile.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.deepTeal, size: 24),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepTeal, fontSize: 15),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                    maxWidth: 600,
                    maxHeight: 600,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImageFile = File(pickedFile.path);
                      _photoProfile = pickedFile.path;
                    });
                  }
                },
              ),
              const Divider(height: 16),
              ListTile(
                leading: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 24),
                title: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Opens a beautiful Date Picker when tapping Date of Birth
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 12, 27),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepTeal,
              onPrimary: Colors.white,
              onSurface: AppTheme.deepTeal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formats as MM/dd/yyyy matching mockup
        final month = picked.month.toString().padLeft(2, '0');
        final day = picked.day.toString().padLeft(2, '0');
        _dobController.text = '$month/$day/${picked.year}';
      });
    }
  }

  // Runs precise visual validations and updates DB
  Future<void> _validateAndSave() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _dobError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final dob = _dobController.text.trim();

    bool isValid = true;

    // 1. Validation: Field cannot be empty
    if (name.isEmpty) {
      _nameError = 'Full Name is required';
      isValid = false;
    }
    if (email.isEmpty) {
      _emailError = 'Email Address is required';
      isValid = false;
    }
    if (phone.isEmpty) {
      _phoneError = 'Phone Number is required';
      isValid = false;
    }
    if (dob.isEmpty) {
      _dobError = 'Date of Birth is required';
      isValid = false;
    }

    // 2. Validation: Email must end in @gmail.com or @email.com
    if (email.isNotEmpty && !email.endsWith('@email.com') && !email.endsWith('@email.com')) {
      _emailError = 'The email address must end in @email.com';
      isValid = false;
    }

    // 3. Validation: Phone number must have a length between 11 and 13
    if (phone.isNotEmpty && (phone.length < 11 || phone.length > 13)) {
      _phoneError = 'Phone number length must be between 11 and 13';
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final int idUser = widget.profileData['id_user'] ?? 1;
    String finalPhotoUrl = _photoProfile;

    if (_selectedImageFile != null) {
      try {
        final String namaFileUnik = 'avatar_${idUser}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('hotel_images')
            .upload(namaFileUnik, _selectedImageFile!);
        
        finalPhotoUrl = Supabase.instance.client.storage
            .from('hotel_images')
            .getPublicUrl(namaFileUnik);
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image to Supabase: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    final apiUser = ApiUser();
    final success = await apiUser.updateUserProfile(
      idUser,
      name,
      phone,
      widget.token,
      photoProfile: finalPhotoUrl,
      email: email,
    );

    if (success) {
      await _saveLocalDob(email, dob);
      ref.invalidate(profileProvider);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.deepTeal,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String defaultHamster = 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=400&q=80';
    final String avatarUrl = _photoProfile.isNotEmpty ? _photoProfile : defaultHamster;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.deepTeal,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppTheme.deepTeal,
            fontSize: 19.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Center aligned circular profile photo
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: SmartImage(
                            path: avatarUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: GestureDetector(
                          onTap: _editProfilePhoto,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C3D3E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _editProfilePhoto,
                    child: const Text(
                      'Change Profile Picture',
                      style: TextStyle(
                        color: AppTheme.deepTeal,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // FULL NAME input box
                  InputBox(
                    label: 'FULL NAME',
                    placeholder: 'Enter your full name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                    errorText: _nameError,
                  ),
                  const SizedBox(height: 20),

                  // EMAIL input box
                  InputBox(
                    label: 'EMAIL',
                    placeholder: 'Enter your email address',
                    controller: _emailController,
                    prefixIcon: Icons.mail_outline_rounded,
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 20),

                  // PHONE NUMBER input box
                  InputBox(
                    label: 'PHONE NUMBER',
                    placeholder: 'Enter your phone number',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                  ),
                  const SizedBox(height: 20),

                  // DATE OF BIRTH input box
                  InputBox(
                    label: 'DATE OF BIRTH',
                    placeholder: 'Select date of birth',
                    controller: _dobController,
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    errorText: _dobError,
                  ),
                  const SizedBox(height: 40),

                  // Save Changes button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _validateAndSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.deepTeal.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
