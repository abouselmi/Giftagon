// lib/models/comment_model.dart

import 'package:hive/hive.dart';

part 'comment_model.g.dart';

@HiveType(typeId: 3)
class Comment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String userName;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? eventId;

  @HiveField(6) // 👈 تأكد أن الرقم غير مستخدم
  final String? wishId;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.eventId,
    this.wishId, // 👈 👈 👈 أضف هذا السطر
  });

  // ... باقي الدوال (toMap, fromMap, copyWith)
}