// lib/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // ██████████████████████████████████████████████████████████████████████
  // █                                                                  █
  // █         🎨 الألوان الأساسية — مبنية على تصميمك السابق           █
  // █                                                                  █
  // ██████████████████████████████████████████████████████████████████████

  // 👑 اللون الأساسي (Primary) — كان: AppTheme.primaryColor = Color(0xFF6A0DAD)
  // → استخدم في: الأزرار، العناوين، التبويبات النشطة، التقدم
  static const Color primary = Color.fromRGBO(
    106,
    13,
    173,
    1.0,
  ); // #6A0DAD — بنفسجي غامق

  // 🎨 اللون الثانوي (Secondary) — كان: Color(0xFFFF6B6B)
  // → استخدم في: أزرار المشاركة، التحذيرات، التنبيهات
  static const Color secondary = Color.fromRGBO(
    255,
    107,
    107,
    1.0,
  ); // #FF6B6B — برتقالي/قرمزي

  // 🖼️ لون الخلفية (Background) — كان: Color(0xFFF5F3FF)
  // → استخدم في: خلفية التطبيق الرئيسية
  static const Color background = Color.fromRGBO(
    245,
    243,
    255,
    1.0,
  ); // #F5F3FF — أبيض مع لمسة بنفسجية

  // 📄 لون خلفية البطاقات (Card) — كان: Colors.white
  // → استخدم في: خلفية البطاقات، الحقول، القوائم
  static const Color cardBackground = Color.fromRGBO(
    255,
    255,
    255,
    1.0,
  ); // #FFFFFF — أبيض نقي

  // 🖋️ لون النص الأساسي — كان: Color(0xFF1E1E1E)
  // → استخدم في: العناوين، النصوص المهمة
  static const Color textPrimary = Color.fromRGBO(
    30,
    30,
    30,
    1.0,
  ); // #1E1E1E — أسود عميق

  // 🖋️ لون النص الثانوي — كان: Color(0xFF6C757D)
  // → استخدم في: الوصف، التواريخ، التفاصيل
  static const Color textSecondary = Color.fromRGBO(
    108,
    117,
    125,
    1.0,
  ); // #6C757D — رمادي متوسط

  // ██████████████████████████████████████████████████████████████████████
  // █                                                                  █
  // █         🎭 ألوان مع شفافية — معرفة مسبقًا — بدون withOpacity     █
  // █                                                                  █
  // ██████████████████████████████████████████████████████████████████████

  // 👑 شفافية 10% من اللون الأساسي — كان: primaryColor.withOpacity(0.1)
  // → استخدم في: خلفية أيقونة البروفايل، خلفية الشريط الجانبي
  static const Color primary10 = Color.fromRGBO(106, 13, 173, 0.1);

  // 👑 شفافية 20% من اللون الأساسي — كان: primaryColor.withOpacity(0.2)
  // → استخدم في: خلفيات خفيفة للعناصر
  static const Color primary20 = Color.fromRGBO(106, 13, 173, 0.2);

  // 👑 شفافية 50% من اللون الأساسي — كان: primaryColor.withOpacity(0.5)
  // → استخدم في: عناصر التقدم، التدرجات
  static const Color primary50 = Color.fromRGBO(106, 13, 173, 0.5);

  // 🎨 شفافية 10% من اللون الثانوي — كان: secondaryColor.withOpacity(0.1)
  // → استخدم في: خلفيات الأزرار الثانوية
  static const Color secondary10 = Color.fromRGBO(255, 107, 107, 0.1);

  // 🎨 شفافية 20% من اللون الثانوي — كان: secondaryColor.withOpacity(0.2)
  // → استخدم في: حالات التحذير الخفيفة
  static const Color secondary20 = Color.fromRGBO(255, 107, 107, 0.2);

  // ⚫ شفافية 10% من الأسود — كان: Colors.black.withOpacity(0.1)
  // → استخدم في: الظلال، الفواصل
  static const Color black10 = Color.fromRGBO(0, 0, 0, 0.1);

  // ⚫ شفافية 20% من الأسود — كان: Colors.black.withOpacity(0.2)
  // → استخدم في: الظلال الأقوى
  static const Color black20 = Color.fromRGBO(0, 0, 0, 0.2);

  // ██████████████████████████████████████████████████████████████████████
  // █                                                                  █
  // █         🟢🟠🔴 ألوان داعمة — للتقدم، الحالات، التنبيهات          █
  // █                                                                  █
  // ██████████████████████████████████████████████████████████████████████

  // 🟢 اللون الأخضر — كان: Colors.green أو Color(0xFF4CAF50)
  // → استخدم في: "تم الإكمال"، "نجاح"
  static const Color green500 = Color.fromRGBO(76, 175, 80, 1.0); // #4CAF50
  // 🟢 شفافية 10% من الأخضر — كان: Colors.green.withOpacity(0.1)
  // → استخدم في: خلفيات النجاح
  static const Color green100 = Color.fromRGBO(76, 175, 80, 0.1);
  // 🟣 اللون البنفسجي — كان: Colors.purple أو Color(0xFF9C27B0)
  // → استخدم في: "مفاجأة"، "خاص"
  static const Color purple500 = Color.fromRGBO(156, 39, 176, 1.0); // #9C27B0
  // 🟣 شفافية 10% من البنفسجي — كان: Colors.purple.withOpacity(0.1)
  // → استخدم في: خلفيات "مفاجأة"
  static const Color purple100 = Color.fromRGBO(156, 39, 176, 0.1);
  // 🔵 اللون الأزرق — كان: Colors.blue أو Color(0xFF2196F3)
  // → استخدم في: التقدم المتوسط، الروابط
  static const Color blue500 = Color.fromRGBO(33, 150, 243, 1.0); // #2196F3
  // 🟠 اللون البرتقالي — كان: Colors.orange أو Color(0xFFFFA726)
  // → استخدم في: التقدم المتوسط، التحذيرات
  static const Color orange500 = Color.fromRGBO(255, 167, 38, 1.0); // #FFA726
  // 🔴 اللون الأحمر — كان: Colors.red أو Color(0xFFF44336)
  // → استخدم في: الأخطاء، الحذف، التحذيرات القوية
  static const Color primaryLight = Color(0xFFA88FE0); // الأرجواني الفاتح
  static const Color accent = Color(0xFF7E5FC1); // لون مميز
  static const Color logout = Color(0xFFF96CA2); // لون الـ Logout
  static const Color eventsBackground = Color(0xFFFDE9ED); // خلفية الأحداث
  // 👇 ألوان التقدم
  static const Color progressGreen = Color(0xFF3CAFA3);
  static const Color progressRed = Color(0xFFFF5A5A);
  static const Color progressBlue = Color(0xFF4FC1FF);
  static const Color progressOrange = Color(0xFFFFB84D);
  static const Color pinky = Color(0xFFF96CA2);
  // 👇 ألوان إضافية للخلفيات والبطاقات
  static const Color divider = Color(0xFFD1D1D1);
}
