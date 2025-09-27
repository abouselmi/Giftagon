// lib/models/contribution_model.dart

import 'package:hive/hive.dart';

part 'contribution_model.g.dart'; // 👈 مهم — للـ Adapter المولد

@HiveType(typeId: 4) // 👈 اختر رقماً غير مستخدم (تأكد من عدم تكراره في WishH, EventH...)
class Contribution extends HiveObject {
  @HiveField(0)
  final String contributorId;

  @HiveField(1)
  final String contributorName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime contributedAt;

  Contribution({
    required this.contributorId,
    required this.contributorName,
    required this.amount,
    required this.contributedAt,
  });

  // 👇 نسخة للتعديل — مفيدة جداً في الواجهات
  Contribution copyWith({
    String? contributorId,
    String? contributorName,
    double? amount,
    DateTime? contributedAt,
  }) {
    return Contribution(
      contributorId: contributorId ?? this.contributorId,
      contributorName: contributorName ?? this.contributorName,
      amount: amount ?? this.amount,
      contributedAt: contributedAt ?? this.contributedAt,
    );
  }
   // 👇 👇 👇 أضفناها عشان ترضي event_model.dart (Firestore style)
  Map<String, dynamic> toMap() {
    return {
      'contributorId': contributorId,
      'contributorName': contributorName,
      'amount': amount,
      'contributedAt': contributedAt, // ⚠️ Hive ما بيدعم Timestamp — لكن Firestore بيدعم
    };
  }
   factory Contribution.fromMap(Map<String, dynamic> map) {
    return Contribution(
      contributorId: map['contributorId'] ?? '',
      contributorName: map['contributorName'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      contributedAt: map['contributedAt'] is DateTime
          ? map['contributedAt'] as DateTime
          : DateTime.tryParse(map['contributedAt'].toString()) ??
              DateTime.now(),
    );
  }
}