// lib/models/hive/event_model_hive.dart

import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import '../comment_model.dart';
import '../contribution_model.dart';

part 'event_model_hive.g.dart';

@HiveType(typeId: 1)
class EventH extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String organizerId;

  @HiveField(4)
  final String organizerName;

  @HiveField(5)
  final double targetAmount;

  @HiveField(6)
  final double currentAmount; // 👈 جعلناه final — لأنه يتغير عبر copyWith فقط

  @HiveField(7)
  final String currency;

  @HiveField(8)
  final String? wishId;

  @HiveField(9)
  final List<Contribution> contributors; // 👈 final

  @HiveField(10)
  final bool isHidden;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime? deadline;

  @HiveField(13)
  final String? imageUrl;

  @HiveField(14)
  final List<Comment> comments;

  EventH({
    required this.id,
    required this.title,
    this.description,
    required this.organizerId,
    required this.organizerName,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.currency,
    this.wishId,
    this.contributors = const [],
    required this.isHidden,
    required this.createdAt,
    this.deadline,
    this.imageUrl,
    this.comments = const [],
  });

  // 👇 دالة لحساب نسبة التقدم
  //double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return ((currentAmount) / targetAmount * 100).clamp(0.0, 100.0);
  }
  // 👇 دالة للتحقق إذا اكتمل الحدث
  bool get isCompleted => currentAmount >= targetAmount;

  // 👇 ✅ التصحيح: نرجع نسخة جديدة بدلاً من التعديل المباشر
  // 👇 دالة لإضافة مساهمة جديدة — ترجع نسخة جديدة
EventH addContribution(String contributorId, String contributorName, double amount) {
  final newContribution = Contribution(
    contributorId: contributorId,
    contributorName: contributorName,
    amount: amount,
    contributedAt: DateTime.now(),
  );

  return copyWith(
    currentAmount: currentAmount + amount,
    contributors: [...contributors, newContribution],
  );
}

// 👇 👇 👇 أضف هذه الدالة الجديدة
EventH removeContribution(String contributorId) {
  final contributionToRemove = contributors.firstWhereOrNull(
    (c) => c.contributorId == contributorId,
   
  );

  if (contributionToRemove == null) return this;

  return copyWith(
    currentAmount: (currentAmount - contributionToRemove.amount).clamp(0.0, double.infinity),
    contributors: contributors.where((c) => c.contributorId != contributorId).toList(),
  );
}
  // 👇 دالة لإنشاء نسخة معدلة من الكائن
  EventH copyWith({
    String? id,
    String? title,
    String? description,
    String? organizerId,
    String? organizerName,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    String? wishId,
    List<Contribution>? contributors,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? deadline,
    String? imageUrl,
    List<Comment>? comments,
  }) {
    return EventH(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      wishId: wishId ?? this.wishId,
      contributors: contributors ?? this.contributors,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      imageUrl: imageUrl ?? this.imageUrl,
      comments: comments ?? this.comments,
    );
  }
}