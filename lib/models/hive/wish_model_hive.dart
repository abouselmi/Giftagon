// lib/models/hive/wish_model_hive.dart

import 'package:hive/hive.dart';
import '../comment_model.dart';
import '../contribution_model.dart';

part 'wish_model_hive.g.dart';

@HiveType(typeId: 0)
class WishH extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final double targetAmount;

  @HiveField(5)
  final double currentAmount; // 👈 جعلناه final

  @HiveField(6)
  final String currency;

  @HiveField(7)
  final String ownerId;

  @HiveField(8)
  final String ownerName;

  @HiveField(9)
  final String circle;

  @HiveField(10)
  final bool isHidden;

  @HiveField(11)
  final String? eventId;

  @HiveField(12)
  final bool isFulfilled; // 👈 جعلناه final

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime? deadline;

  @HiveField(15)
  final List<Contribution> contributors; // 👈 final

  @HiveField(16)
  final List<Comment> comments;

  WishH({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.currency,
    required this.ownerId,
    required this.ownerName,
    required this.circle,
    required this.isHidden,
    this.eventId,
    this.isFulfilled = false,
    required this.createdAt,
    this.deadline,
    this.contributors = const [],
    this.comments = const [],
  });

  // 👇 دالة لحساب نسبة التقدم
  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;

  // 👇 دالة للتحقق إذا اكتملت — (isFulfilled || currentAmount >= targetAmount)
  bool get isCompleted => isFulfilled || currentAmount >= targetAmount;

  // 👇 ✅ التصحيح: نرجع نسخة جديدة بدلاً من التعديل المباشر
  WishH addContribution(
    String contributorId,
    String contributorName,
    double amount,
  ) {
    final newContribution = Contribution(
      contributorId: contributorId,
      contributorName: contributorName,
      amount: amount,
      contributedAt: DateTime.now(),
    );

    final newCurrentAmount = currentAmount + amount;
    final newIsFulfilled = isFulfilled || newCurrentAmount >= targetAmount;

    return copyWith(
      currentAmount: newCurrentAmount,
      isFulfilled: newIsFulfilled,
      contributors: [...contributors, newContribution],
    );
  }

  WishH removeContribution(String contributorId) {
    // 👇 ننشئ قيمة وهمية للتعرف عليها
    final dummy = Contribution(
      contributorId: '',
      contributorName: '',
      amount: 0.0,
      contributedAt: DateTime.now(),
    );

    final contributionToRemove = contributors.firstWhere(
      (c) => c.contributorId == contributorId,
      orElse: () => dummy,
    );

    if (contributionToRemove.contributorId.isEmpty) return this;

    final newCurrentAmount = (currentAmount - contributionToRemove.amount)
        .clamp(0.0, double.infinity);
    final newIsFulfilled = newCurrentAmount >= targetAmount;

    return copyWith(
      currentAmount: newCurrentAmount,
      isFulfilled: newIsFulfilled,
      contributors: contributors
          .where((c) => c.contributorId != contributorId)
          .toList(),
    );
  }

  // 👇 دالة لإنشاء نسخة معدلة من الكائن
  WishH copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    String? ownerId,
    String? ownerName,
    String? circle,
    bool? isHidden,
    String? eventId,
    bool? isFulfilled,
    DateTime? createdAt,
    DateTime? deadline,
    List<Contribution>? contributors,
    List<Comment>? comments,
  }) {
    return WishH(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      circle: circle ?? this.circle,
      isHidden: isHidden ?? this.isHidden,
      eventId: eventId ?? this.eventId,
      isFulfilled: isFulfilled ?? this.isFulfilled,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      contributors: contributors ?? this.contributors,
      comments: comments ?? this.comments,
    );
  }
}
