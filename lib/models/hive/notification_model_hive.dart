// lib/models/hive/notification_model_hive.dart

import 'package:hive/hive.dart';

part 'notification_model_hive.g.dart';

@HiveType(typeId: 5)
class NotificationH extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId; // المستخدم اللي استلم الإشعار

  @HiveField(2)
  final String fromUserId; // من أرسل الإشعار

  @HiveField(3)
  final String fromUserName;

  @HiveField(4)
  final String type; // "comment", "like", "contribution", "event", "system"

  @HiveField(5)
  final String title;

  @HiveField(6)
  final String message;

  @HiveField(7)
  final String? relatedId; // معرف الهدية / الحدث / التعليق المرتبط

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  bool isRead;

  NotificationH({
    required this.id,
    required this.userId,
    required this.fromUserId,
    required this.fromUserName,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    required this.createdAt,
    this.isRead = false,
  });

  // 👇 نسخة معدلة
  NotificationH copyWith({
    String? id,
    String? userId,
    String? fromUserId,
    String? fromUserName,
    String? type,
    String? title,
    String? message,
    String? relatedId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationH(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}