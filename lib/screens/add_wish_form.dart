// lib/screens/add_wish_form.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gift/Services/image_picker_service.dart';
import '../constants/app_colors.dart';
import '../models/hive/wish_model_hive.dart';
import '../providers.dart';
import 'dart:typed_data'; // 👈 لـ Uint8List
import 'package:http/http.dart' as http; // ✅ حديث ومدعوم

class AddWishFormScreen extends ConsumerStatefulWidget {
  final WishH? initialWish;
  const AddWishFormScreen({super.key, this.initialWish});


  @override
  ConsumerState<AddWishFormScreen> createState() => _AddWishFormScreenState();
}

class _AddWishFormScreenState extends ConsumerState<AddWishFormScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _imageController;
  late String _selectedCircle;
  late bool _isHidden;
  late bool _isLinkedToEvent;
  late DateTime? _selectedDate;
  late String? _selectedImagePath;

  Future<Uint8List?> _loadImageBytes(String imagePath) async {
    try {
      if (kIsWeb) {
        // 👉 في الويب — نستخدم XMLHttpRequest لتحميل الصورة كـ Uint8List
        final response = await http.get(Uri.parse(imagePath));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        } else {
          debugPrint('Failed to load image: ${response.statusCode}');
          return null;
        }
        // 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆
      } else {
        final file = File(imagePath);
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // 👇 استرداد الصورة المفقودة عند إعادة فتح الشاشة
    _retrieveLostImage();
  }
  Future<void> _retrieveLostImage() async {
    final lostFile = await ImagePickerService().retrieveLostImage();
    if (lostFile != null) {
      setState(() {
        _selectedImagePath = lostFile.path;
      });
    }
  }
  void _initializeControllers() {
    if (widget.initialWish != null) {
      _titleController = TextEditingController(text: widget.initialWish!.title);
      _descriptionController = TextEditingController(text: widget.initialWish!.description ?? "");
      _amountController = TextEditingController(text: widget.initialWish!.targetAmount.toString());
      //_imageController = TextEditingController(text: widget.initialWish!.imageUrl ?? "");
      _selectedCircle = widget.initialWish!.circle;
      _isHidden = widget.initialWish!.isHidden;
      _isLinkedToEvent = widget.initialWish!.eventId != null;
      _selectedDate = widget.initialWish!.deadline;
      _selectedImagePath = widget.initialWish!.imageUrl; // 👈 نحمل المسار إذا كان موجودًا
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _amountController = TextEditingController();
      //_imageController = TextEditingController();
      _selectedCircle = "friends";
      _isHidden = false;
      _isLinkedToEvent = false;
      _selectedDate = null;
      _selectedImagePath = null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePickerService.pickImageFromGallery(
      maxHeight: 600,
          maxWidth: 800,
        imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path; // 👈 نحفظ مسار الملف
      });
    }
  }

  void _saveWish() async {
    if (_titleController.text.trim().isEmpty || _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال الاسم والمبلغ!")),
      );
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("المبلغ يجب أن يكون أكبر من صفر!")),
      );
      return;
    }

    final user = ref.read(userNotifierProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ: المستخدم غير مسجل")),
      );
      return;
    }

    final wishNotifier = ref.read(wishNotifierProvider.notifier);

    if (widget.initialWish != null) {
      final updatedWish = widget.initialWish!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        targetAmount: amount,
        //imageUrl: _imageController.text.trim().isNotEmpty ? _imageController.text.trim() : null,
        imageUrl: _selectedImagePath,
        circle: _selectedCircle,
        isHidden: _isHidden,
        eventId: _isLinkedToEvent ? "event_placeholder_id" : null,
        deadline: _selectedDate,
      );
      await wishNotifier.updateWish(updatedWish);
    } else {
      final newWish = WishH(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        //imageUrl: _imageController.text.trim().isNotEmpty ? _imageController.text.trim() : null,
        imageUrl: _selectedImagePath,
        targetAmount: amount,
        currentAmount: 0.0,
        currency: "USD",
        ownerId: user.id,
        ownerName: user.name,
        circle: _selectedCircle,
        isHidden: _isHidden,
        eventId: _isLinkedToEvent ? "event_placeholder_id" : null,
        isFulfilled: false,
        createdAt: DateTime.now(),
        deadline: _selectedDate,
        contributors: [],

      );
      await wishNotifier.addWish(newWish);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${widget.initialWish != null ? "تم تحديث" : "تم إضافة"} الهدية: ${_titleController.text} ✅",
        ),
        backgroundColor: Colors.green,
      ),
    );

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
          widget.initialWish != null ? "تعديل الهدية" : "إضافة هدية جديدة",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TextButton(
            onPressed: _saveWish,
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
            // 👉 حقل اسم الهدية
            Text("اسم الهدية *", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: "مثال: AirPods Pro",
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),

            // 👉 حقل رابط الصورة
            Text(
              "رابط الصورة (اختياري)",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImagePath != null
                    ? FutureBuilder<Uint8List?>(
                  future: _loadImageBytes(_selectedImagePath!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return const Center(child: Icon(Icons.error));
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: Colors.grey),
                      Text(
                        "اختر صورة",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 👉 حقل الوصف
            Text(
              "الوصف (اختياري)",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: "لماذا هذه الهدية مهمة؟",
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),

            // 👉 حقل المبلغ المستهدف
            Text(
              "المبلغ المستهدف *",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixText: "\$ ",
                hintText: "120",
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),

            // 👉 اختيار الدائرة الاجتماعية
            Text(
              "الدائرة الاجتماعية *",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                _buildCircleChip("family", "عائلة", Icons.family_restroom),
                _buildCircleChip("friends", "أصدقاء", Icons.people),
                _buildCircleChip("others", "آخرون", Icons.person_outline),
              ],
            ),
            const SizedBox(height: 20),

            // 👉 تبديل "إخفاء كمفاجأة"
            Row(
              children: [
                const Icon(Icons.visibility_off, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  "إخفاء كمفاجأة؟",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Switch(
                  value: _isHidden,
                  onChanged: (value) {
                    setState(() {
                      _isHidden = value;
                    });
                  },
                  activeThumbColor: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 👉 تبديل "ربط بحدث جماعي"
            Row(
              children: [
                const Icon(Icons.event, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  "ربط بحدث جماعي؟",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Switch(
                  value: _isLinkedToEvent,
                  onChanged: (value) {
                    setState(() {
                      _isLinkedToEvent = value;
                    });
                  },
                  activeThumbColor: AppColors.primary10,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 👉 اختيار تاريخ الاستحقاق
            Text(
              "تاريخ الاستحقاق",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                          : "اختر تاريخًا",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleChip(String value, String label, IconData icon) {
    return FilterChip(
      selected: _selectedCircle == value,
      onSelected: (selected) {
        setState(() {
          _selectedCircle = value;
        });
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: _selectedCircle == value ? Colors.white : null,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary10,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}