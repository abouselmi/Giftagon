// lib/utils/layout_utils.dart

import 'package:flutter/material.dart';

import '../models/hive/wish_model_hive.dart';

/// دالة لبناء قسم الهدايا — تستخدم في DashboardScreen و WishListScreen
Widget buildGiftListSection(
    BuildContext context,
    List<WishH> wishes, {
      required bool isMobile,
      required Function(WishH) onWishTap,
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '2021\nAugust',
        style: TextStyle(
          fontSize: isMobile ? 36 : 48,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1B2A33),
          height: 1.1,
        ),
      ),
      const SizedBox(height: 24),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: wishes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final wish = wishes[index];
          return buildGiftListItem(context, wish,
              isMobile: isMobile, onTap: () => onWishTap(wish));
        },
      ),
      const SizedBox(height: 24),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: () {
            // 👈 هنا نضيف منطق إضافة هدية جديدة
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add New Gift'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B3E8C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
  );
}

/// دالة لبناء بطاقة هدية — تستخدم في عدة شاشات
Widget buildGiftListItem(
    BuildContext context,
    WishH wish, {
      required bool isMobile,
      required VoidCallback onTap,
    }) {
  Color getProgressColor(double percentage) {
    if (percentage >= 100) return Colors.green;
    if (percentage >= 75) return const Color(0xFF3CAFA3);
    if (percentage >= 50) return const Color(0xFFFF5A5A);
    if (percentage >= 25) return const Color(0xFF4FC1FF);
    return const Color(0xFFFFB84D);
  }

  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D1D1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: const Color(0xFFD1D1D1)),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              wish.deadline?.day.toString() ?? "??",
              style: const TextStyle(
                color: Color(0xFF5B3E8C),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: getProgressColor(wish.progressPercentage),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    wish.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: getProgressColor(wish.progressPercentage),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                      topRight: Radius.circular(9999),
                      bottomRight: Radius.circular(9999),
                    ),
                  ),
                  child: Text(
                    '${wish.progressPercentage.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.share,
                    size: 18,
                    color: Color(0xFF7B7B7B),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Color(0xFF7B7B7B),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      )
          : Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: const Color(0xFFD1D1D1)),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              wish.deadline?.day.toString() ?? "??",
              style: const TextStyle(
                color: Color(0xFF5B3E8C),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: getProgressColor(wish.progressPercentage),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      wish.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: getProgressColor(wish.progressPercentage),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                        topRight: Radius.circular(9999),
                        bottomRight: Radius.circular(9999),
                      ),
                    ),
                    child: Text(
                      '${wish.progressPercentage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.share,
                    size: 18,
                    color: Color(0xFF7B7B7B),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Color(0xFF7B7B7B),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}