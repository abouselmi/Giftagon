// lib/screens/add_event_form_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Services/image_picker_service.dart';
import '../constants/app_colors.dart';
import '../models/hive/event_model_hive.dart';
import '../providers.dart';

class AddEventFormScreen extends ConsumerStatefulWidget {
  final EventH? initialEvent;
  final DateTime? initialDate; // 👈 لتلقي التاريخ من CalendarScreen
  const AddEventFormScreen({
    super.key,
    this.initialEvent,
    this.initialDate,
  });

  @override
  ConsumerState<AddEventFormScreen> createState() => _AddEventFormScreenState();
}

class _AddEventFormScreenState extends ConsumerState<AddEventFormScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  // 👇 تم حذف _imageController — لأنه لم يعد مستخدمًا
  late String _selectedCircle;
  late bool _isHidden;
  late DateTime? _selectedDate;
  late String? _selectedImagePath; // 👈 لحفظ مسار الصورة المختارة

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
    if (widget.initialEvent != null) {
      _titleController = TextEditingController(text: widget.initialEvent!.title);
      _descriptionController = TextEditingController(text: widget.initialEvent!.description ?? "");
      _amountController = TextEditingController(text: widget.initialEvent!.targetAmount.toString());
      // 👇 تم حذف تهيئة _imageController
      _selectedCircle = "friends";
      _isHidden = widget.initialEvent!.isHidden;
      _selectedDate = widget.initialEvent!.deadline;
      _selectedImagePath = widget.initialEvent!.imageUrl; // 👈 نحمل مسار الصورة إذا كان موجودًا
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _amountController = TextEditingController();
      // 👇 تم حذف تهيئة _imageController
      _selectedCircle = "friends";
      _isHidden = false;
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedImagePath = null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 👇 دالة اختيار الصورة — تم إصلاحها
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

  void _saveEvent() async {
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

    final eventNotifier = ref.read(eventNotifierProvider.notifier);

    if (widget.initialEvent != null) {
      final updatedEvent = widget.initialEvent!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        targetAmount: amount,
        isHidden: _isHidden,
        deadline: _selectedDate,
        imageUrl: _selectedImagePath, // 👈 نحفظ مسار الصورة
      );
      await eventNotifier.updateEvent(updatedEvent);
    } else {
      final newEvent = EventH(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        organizerId: user.id,
        organizerName: user.name,
        targetAmount: amount,
        currentAmount: 0.0,
        currency: "USD",
        wishId: null,
        contributors: [],
        isHidden: _isHidden,
        createdAt: DateTime.now(),
        deadline: _selectedDate,
        imageUrl: _selectedImagePath, // 👈 نحفظ مسار الصورة
        comments: [],
      );
      await eventNotifier.addEvent(newEvent);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${widget.initialEvent != null ? "تم تحديث" : "تم إضافة"} الحدث: ${_titleController.text} ✅",
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
          widget.initialEvent != null ? "تعديل الحدث" : "إضافة حدث جديد",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TextButton(
            onPressed: _saveEvent,
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
            // 👉 حقل اسم الحدث
            Text("اسم الحدث *", style: Theme.of(context).textTheme.titleLarge),
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
                hintText: "مثال: عيد ميلاد سارة",
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),

            // 👉 حقل اختيار الصورة — جديد
            Text(
              "صورة الحدث (اختياري)",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage, // 👈 عند النقر
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImagePath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedImagePath!), // 👈 عرض الصورة المختارة
                    fit: BoxFit.cover,
                  ),
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
                hintText: "تفاصيل الحدث وأهميته",
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
                hintText: "500",
                contentPadding: const EdgeInsets.all(16),
              ),
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    // 👇 تم حذف _imageController.dispose()
    super.dispose();
  }
}