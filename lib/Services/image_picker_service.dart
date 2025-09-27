// lib/Services/image_picker_service.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();
// 👇 دالة لاسترداد البيانات المفقودة
  Future<XFile?> retrieveLostImage() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) return null;
    return response.file;
  }

  // 👇 دالة اختيار صورة من المعرض — مع معلمات اختيارية
  Future<XFile?> pickImageFromGallery({
    double maxWidth= 800,
    double maxHeight= 600,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return pickedFile;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // 👇 دالة التقاط صورة من الكاميرا — مع معلمات اختيارية
  Future<XFile?> takePhotoFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      // 👇 التحقق أولاً إذا كان الجهاز يدعم الكاميرا
      if (!_picker.supportsImageSource(ImageSource.camera)) {
        debugPrint('Camera not supported on this device.');
        return null;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return pickedFile;
    } catch (e) {
      debugPrint('Error taking photo from camera: $e');
      return null;
    }
  }

  // 👇 (اختياري) دالة لعرض حوار اختيار المصدر — المعرض أو الكاميرا
  Future<XFile?> pickImage(BuildContext context) async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('اختر من المعرض'),
                  onTap: () async {
                    final file = await pickImageFromGallery();
                    if (file != null) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
                if (_picker.supportsImageSource(ImageSource.camera))
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('التقط صورة'),
                    onTap: () async {
                      final file = await takePhotoFromCamera();
                      if (file != null) {
                        Navigator.pop(context, file);
                      }
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('إلغاء'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}