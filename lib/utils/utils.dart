// lib/utils/image_utils.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// 👇 دالة لتحميل الصورة كـ Uint8List (تدعم الويب + الموبايل/ويندوز)
Future<Uint8List?> loadImageBytes(String? imagePath) async {
  if (imagePath == null || imagePath.isEmpty) return null;
  try {
    if (kIsWeb) {
      // لو الرابط من الإنترنت
      if (imagePath.startsWith('http')) {
        final response = await http.get(Uri.parse(imagePath));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
      }
      // في الويب: الملفات المحلية غير مدعومة → نرجع null
      return null;
    } else {
      // في الموبايل/ويندوز
      if (imagePath.startsWith('http')) {
        final response = await http.get(Uri.parse(imagePath));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
      } else {
        // مسار ملف محلي (من Hive أو File)
        final file = File(imagePath);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
    }
  } catch (e) {
    debugPrint('Error loading image: $e');
  }
  return null;
}

// 👇 دالة لتحديد نوع ImageProvider
ImageProvider getImageProvider(
    String? imageUrl, {
      Uint8List? imageBytes,
    }) {
  // 1. لو عندنا bytes جاهزة (من Hive أو loadImageBytes)
  if (imageBytes != null) {
    return MemoryImage(imageBytes);
  }

  // 2. لو ما فيش مسار → رجع أيقونة افتراضية محلية
  if (imageUrl == null || imageUrl.isEmpty) {
    return const AssetImage("assets/images/placeholder.png");
  }

  // 3. روابط الإنترنت
  if (imageUrl.startsWith("http://") || imageUrl.startsWith("https://")) {
    return NetworkImage(imageUrl);
  }

  // 4. ملفات محلية (بس مش على الويب)
  if (!kIsWeb) {
    return FileImage(File(imageUrl));
  }

  // 5. fallback للويب → Placeholder محلي
  return const AssetImage("assets/images/placeholder.png");
}
