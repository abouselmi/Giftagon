// lib/screens/wish_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/contribution_model.dart';
import '../models/hive/user_model_hive.dart';
import '../models/hive/wish_model_hive.dart';
import '../providers.dart';
import 'wish_detail_screen.dart';

class WishListScreen extends ConsumerStatefulWidget {
  const WishListScreen({super.key});

  @override
  ConsumerState<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends ConsumerState<WishListScreen> {
  String _filter = "all";

  @override
  Widget build(BuildContext context) {
    final wishesAsync = ref.watch(wishNotifierProvider);
    final user = ref.read(userNotifierProvider).value;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("خطأ: المستخدم غير مسجل")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        title: Text(
          "قائمة الهدايا",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 👈 إضافة شريط بحث لاحقًا
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 👉 شريط الفلترة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  "فلترة: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: "all", child: Text("الكل")),
                    DropdownMenuItem(
                      value: "for_you",
                      child: Text("لك"),
                    ),
                    DropdownMenuItem(
                      value: "others",
                      child: Text("للآخرين"),
                    ),
                    DropdownMenuItem(
                      value: "completed",
                      child: Text("مكتملة"),
                    ),
                    DropdownMenuItem(
                      value: "hidden",
                      child: Text("مفاجآت"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filter = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          // 👉 قائمة الهدايا
          Expanded(
            child: wishesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
                 data: (wishes) {
                final filteredWishes = _getFilteredWishes(wishes, user);
                if (filteredWishes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.card_giftcard, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "لا توجد هدايا مطابقة للفلتر",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredWishes.length,
                  itemBuilder: (context, index) {
                    return _buildWishCard(context, filteredWishes[index], user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<WishH> _getFilteredWishes(List<WishH> wishes, UserH user) {
    List<WishH> filtered = wishes;

    switch (_filter) {
      case "for_you":
        filtered = wishes.where((wish) => wish.ownerId == user.id).toList();
        break;
      case "others":
        filtered = wishes.where((wish) => wish.ownerId != user.id).toList();
        break;
      case "completed":
        filtered = wishes.where((wish) => wish.isCompleted).toList();
        break;
      case "hidden":
        filtered = wishes.where((wish) => wish.isHidden).toList();
        break;
      default:
      // "all" — لا حاجة لفلترة
        break;
    }

    // 👉 إخفاء المفاجآت الخاصة إذا لم تكن لك
    return filtered.where((wish) {
      return !wish.isHidden || wish.ownerId == user.id;
    }).toList();
  }

  Widget _buildWishCard(BuildContext context, WishH wish, UserH user) {
    Color getProgressColor(double percentage) {
      if (percentage >= 100) return Colors.green;
      if (percentage >= 75) return AppColors.primary;
      if (percentage >= 50) return Colors.blue;
      if (percentage >= 25) return Colors.orange;
      return Colors.red;
    }

    final isOwner = wish.ownerId == user.id;
    final isParticipant = wish.contributors.any((c) => c.contributorId == user.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WishDetailScreen(wishId: wish.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👉 العنوان ونوع الهدية
              Row(
                children: [
                  if (isOwner)
                    const Icon(Icons.card_giftcard, color: AppColors.primary),
                  if (!isOwner)
                    const Icon(Icons.group, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOwner
                          ? "هدية طلبتها: ${wish.title}"
                          : "هدية لـ ${wish.ownerName}: ${wish.title}",
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 👉 شريط التقدم
              LinearProgressIndicator(
                value: wish.progressPercentage / 100,
                backgroundColor: Colors.grey[200],
                color: getProgressColor(wish.progressPercentage),
                borderRadius: BorderRadius.circular(8),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              // 👉 المبلغ
              Text(
                "${wish.currency}${wish.currentAmount.toStringAsFixed(0)} من ${wish.currency}${wish.targetAmount.toStringAsFixed(0)} (${wish.progressPercentage.toStringAsFixed(0)}%)",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              // 👉 الوصف
              if (wish.description != null)
                Text(
                  wish.description!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              // 👉 تاريخ الإنشاء

                Text(
                  "تم إنشاؤها في: ${wish.createdAt.day}/${wish.createdAt.month}/${wish.createdAt.year}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 16),
              // 👉 أزرار التفاعل
              Row(
                children: [
                  // 👉 زر الإعجاب
                  GestureDetector(
                    onTap: () async {
                      if (wish.contributors.any((c) => c.contributorId == user.id)) {
                        // 👉 إذا كنت معجبًا — نزيل الإعجاب
                        final updatedWish = wish.removeContribution(user.id);
                        await ref.read(wishNotifierProvider.notifier).updateWish(updatedWish);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم إزالة الإعجاب")),
                        );
                      } else {
                        // 👉 إذا لم تكن معجبًا — نضيف إعجاب
                        final updatedWish = wish.addContribution(
                          user.id,
                          user.name,
                          1.0,
                        );
                        await ref.read(wishNotifierProvider.notifier).updateWish(updatedWish);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم الإعجاب بالهدية!")),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: isParticipant ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${wish.contributors.length}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // 👉 زر المشاركة
                  if (!isParticipant && !isOwner)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final updatedWish = wish.addContribution(
                          user.id,
                          user.name,
                          20.0,
                        );
                        await ref.read(wishNotifierProvider.notifier).updateWish(updatedWish);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("ساهمت بـ \$20 في هدية: ${wish.title}!"),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.attach_money),
                      label: const Text("شارك"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  // 👉 زر الانسحاب
                  if (isParticipant && !isOwner)
                    OutlinedButton.icon(
                      onPressed: () {
                        _confirmWithdraw(context, wish, ref);
                      },
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text("انسحب"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  const Spacer(),
                  // 👉 زر المشاركة (نسخ الرابط)
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تم نسخ رابط الهدية!")),
                      );
                    },
                  ),
                ],
              ),
              // 👉 علامة "مفاجأة خاصة"
              if (wish.isHidden)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.visibility_off, size: 16, color: Colors.purple),
                      SizedBox(width: 4),
                      Text(
                        "مفاجأة خاصة!",
                        style: TextStyle(fontSize: 12, color: Colors.purple),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmWithdraw(BuildContext context, WishH wish, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الانسحاب"),
        content: const Text(
          "هل أنت متأكد أنك تريد الانسحاب من هذه الهدية؟ سيتم خصم مساهمتك.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              final contribution = wish.contributors.firstWhere(
                    (c) => c.contributorId == ref.read(userNotifierProvider).value!.id,
                orElse: () => Contribution(
                  contributorId: "",
                  contributorName: "",
                  amount: 0.0,
                  contributedAt: DateTime.now(),
                ),
              );
              if (contribution.contributorId.isNotEmpty) {
                final updatedWish = wish.removeContribution(
                  ref.read(userNotifierProvider).value!.id,
                );
                await ref.read(wishNotifierProvider.notifier).updateWish(updatedWish);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("تم الانسحاب من الهدية وخصم المبلغ!"),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text("انسحب"),
          ),
        ],
      ),
    );
  }
}