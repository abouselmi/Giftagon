// lib/screens/profile_settings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:http/http.dart' as http;
import '../Services/hive_service.dart';
import '../Services/image_picker_service.dart';
import '../constants/app_colors.dart';
import '../models/hive/user_model_hive.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});
  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final HiveService _hiveService = HiveService();
  final ImagePickerService _imagePickerService = ImagePickerService();

  late UserH _user;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _countryController;
  late bool _isPublic;
  late bool _receiveNotifications;
  late String? _selectedImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = _hiveService.getUser();
    if (user != null) {
      setState(() {
        _user = user;
        _selectedImagePath = user.avatarUrl; // 👈 تحميل صورة المستخدم
        _nameController = TextEditingController(text: user.name);
        _emailController = TextEditingController(text: user.email);
        _ageController = TextEditingController(text: user.age.toString());
        _countryController = TextEditingController(text: user.country);
        _isPublic = user.isPublic;
        _receiveNotifications = user.receiveNotifications;
      });
    } else {
      final newUser = UserH(
        id: "u123",
        name: "ABOUSELMI",
        email: "abouselmi@example.com",
        age: 25,
        country: "Palestine",
      );
      _hiveService.saveUser(newUser);
      setState(() {
        _user = newUser;
        _selectedImagePath = null;
        _nameController = TextEditingController(text: newUser.name);
        _emailController = TextEditingController(text: newUser.email);
        _ageController = TextEditingController(text: newUser.age.toString());
        _countryController = TextEditingController(text: newUser.country);
        _isPublic = newUser.isPublic;
        _receiveNotifications = newUser.receiveNotifications;
      });
    }
  }

  // 👇 دالة تحميل الصورة كـ Uint8List للويب
  Future<Uint8List?> _loadImageBytes(String imagePath) async {
    try {
      if (kIsWeb) {
        final response = await http.get(Uri.parse(imagePath));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
      } else {
        final file = File(imagePath);
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
    return null;
  }

  // 👇 دالة اختيار الصورة
  Future<void> _pickImage() async {
    final pickedFile = await _imagePickerService.pickImageFromGallery(
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  void _saveProfile() {
    final updatedUser = _user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      age: int.tryParse(_ageController.text) ?? _user.age,
      country: _countryController.text.trim(),
      isPublic: _isPublic,
      receiveNotifications: _receiveNotifications,
      avatarUrl: _selectedImagePath, // 👈 حفظ مسار الصورة
    );
    _hiveService.saveUser(updatedUser);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم حفظ التعديلات! ✅"),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _user = updatedUser;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        title: Text(
          "تعديل الملف الشخصي",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              "حفظ",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  // 👉 عرض الصورة المختارة
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary10,
                    child: _selectedImagePath != null
                        ? FutureBuilder<Uint8List?>(
                      future: _loadImageBytes(_selectedImagePath!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return CircleAvatar(
                            radius: 60,
                            backgroundImage: MemoryImage(snapshot.data!),
                          );
                        } else {
                          return const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 60,
                          );
                        }
                      },
                    )
                        : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      backgroundColor: AppColors.primary,
                      onPressed: _pickImage, // 👈 عند النقر
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // ... (باقي الحقول: الاسم، البريد، العمر، الدولة، الإعدادات)
            Text(
              "الاسم الكامل *",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "البريد الإلكتروني *",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            Text("العمر", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            Text("الدولة", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _countryController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "الإعدادات",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("جعل الملف العام"),
              subtitle: const Text("يمكن للآخرين رؤية هداياك ومشاركاتك"),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              title: const Text("استقبال الإشعارات"),
              subtitle: const Text("عند التعليق أو الإعجاب أو تحقيق هدية"),
              value: _receiveNotifications,
              onChanged: (value) {
                setState(() {
                  _receiveNotifications = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () {
                  _confirmDeleteAccount(context);
                },
                child: const Text(
                  "حذف الحساب",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد حذف الحساب"),
        content: const Text(
          "هل أنت متأكد؟ هذه العملية لا رجعة فيها وسيتم حذف كل بياناتك.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم حذف الحساب! 👋"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              "حذف نهائي",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

}
