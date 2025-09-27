// lib/models/hive/user_model_hive.dart
import 'package:hive/hive.dart';

part 'user_model_hive.g.dart';

@HiveType(typeId: 2)
class UserH extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String email;
  @HiveField(3)
  int age;
  @HiveField(4)
  String country;
  @HiveField(5)
  bool isPublic;
  @HiveField(6)
  bool receiveNotifications;
  @HiveField(7) // 👈 الحقل الجديد
  final String? avatarUrl; // 👈 رابط صورة المستخدم
  @HiveField(8)
  final bool isAdmin; // 👈 جديد

  UserH({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.country,
    this.isPublic = true,
    this.receiveNotifications = true,
    this.avatarUrl, // 👈 تمت إضافته هنا
    this.isAdmin=false,
  });

  // 👇 دالة لإنشاء نسخة معدلة
  UserH copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? country,
    bool? isPublic,
    bool? receiveNotifications,
    String? avatarUrl, // 👈 هنا أيضًا
    bool? isAdmin,
  }) {
    return UserH(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      country: country ?? this.country,
      isPublic: isPublic ?? this.isPublic,
      receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      avatarUrl: avatarUrl ?? this.avatarUrl, // 👈 وهنا
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}