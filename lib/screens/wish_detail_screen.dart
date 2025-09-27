// lib/screens/wish_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/comment_model.dart';
import '../models/contribution_model.dart';
import '../models/hive/wish_model_hive.dart';
import '../providers.dart';

class WishDetailScreen extends ConsumerStatefulWidget {
  final String wishId;
  const WishDetailScreen({super.key, required this.wishId});

  @override
  ConsumerState<WishDetailScreen> createState() => _WishDetailScreenState();
}

class _WishDetailScreenState extends ConsumerState<WishDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final wishesAsync = ref.watch(wishNotifierProvider);

    return wishesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (wishes) {
        final wish = wishes.firstWhere((w) => w.id == widget.wishId);
        final user = ref.read(userNotifierProvider).value;
        if (user == null) {
          return const Center(child: Text("خطأ: المستخدم غير مسجل"));
        }

        final isOwner = wish.ownerId == user.id;
        final isParticipant = wish.contributors.any(
          (c) => c.contributorId == user.id,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "تفاصيل الهدية",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👉 عنوان الهدية
                Text(
                  wish.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                // 👉 طلبها
                Text(
                  "طلبها: ${wish.ownerName}",
                  style: TextStyle(
                    color: AppColors.primary10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // 👉 الوصف
                if (wish.description != null)
                  Text(
                    wish.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 16),
                // 👉 شريط التقدم
                LinearProgressIndicator(
                  value: wish.progressPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  color: _getProgressColor(wish.progressPercentage),
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 12,
                ),
                const SizedBox(height: 8),
                // 👉 المبلغ
                Text(
                  "${wish.currency}${wish.currentAmount.toStringAsFixed(0)} من ${wish.currency}${wish.targetAmount.toStringAsFixed(0)} (${wish.progressPercentage.toStringAsFixed(0)}%)",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                // 👉 أزرار التفاعل
                if (!isParticipant && !isOwner)
                  OutlinedButton.icon(
                    onPressed: () {
                      _showContributionDialog(context, wish, ref);
                    },
                    icon: const Icon(Icons.attach_money),
                    label: const Text("ساهم الآن"),
                  ),
                Row(
                  children: [
                    if (!isParticipant && !isOwner)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final updatedWish = wish.addContribution(
                            user.id,
                            user.name,
                            20.0,
                          );
                          await ref
                              .read(wishNotifierProvider.notifier)
                              .updateWish(updatedWish);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("تمت المشاركة في الهدية!"),
                            ),
                          );
                        },
                        icon: const Icon(Icons.attach_money),
                        label: const Text("ساهم الآن"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary10,
                        ),
                      ),
                    if (isParticipant && !isOwner)
                      OutlinedButton.icon(
                        onPressed: () {
                          _confirmWithdraw(context, wish, ref);
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text("انسحب"),
                      ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showCommentsBottomSheet(context, wish, ref);
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text("التعليقات"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 👉 قائمة المساهمين
                Text(
                  "المساهمون (${wish.contributors.length})",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                ...wish.contributors.map(
                  (contributor) => _buildContributorTile(contributor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContributionDialog(BuildContext context, WishH wish, WidgetRef ref) {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("اختر مبلغ المساهمة"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("المبلغ الكامل"),
              subtitle: Text("\$${wish.targetAmount}"),
              trailing: Radio<String>(
                value: "full",
                groupValue: "full",
                onChanged: (value) {
                  amountController.text = wish.targetAmount.toString();
                },
              ),
            ),
            ListTile(
              title: const Text("مبلغ مخصص"),
              trailing: Radio<String>(
                value: "custom",
                groupValue: "custom",
                onChanged: (value) {
                  amountController.text = "20.0";
                },
              ),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "المبلغ (\$)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("المبلغ يجب أن يكون أكبر من صفر")),
                );
                return;
              }
              final user = ref.read(userNotifierProvider).value!;
              final updatedWish = wish.addContribution(user.id, user.name, amount);
              await ref.read(wishNotifierProvider.notifier).updateWish(updatedWish);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ساهمت بـ \$${amount.toStringAsFixed(2)} في الهدية!")),
              );
            },
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );
  }
  Widget _buildCommentTile(Comment comment) {
    final user = ref.read(userNotifierProvider).value;
    // 👇 نبحث عن المستخدم في قاعدة البيانات (هنا نحتاج تعديل بسيط في HiveService لاحقًا)
    // لكن كحل سريع، نعرض الحرف الأول إذا لم يكن لدينا رابط صورة
    String? avatarUrl;
    // 👈 هنا يمكنك لاحقًا جلب المستخدم من HiveService للحصول على avatarUrl
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary20,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [

            CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl!)),

            CircleAvatar(
              backgroundColor: AppColors.primary10,
              radius: 16,
              child: Text(
                comment.userName.characters.first,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            _formatTimeAgo(comment.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showCommentsBottomSheet(
    BuildContext context,
    WishH wish,
    WidgetRef ref,
  ) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "التعليقات (${wish.comments.length})",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: wish.comments.length,
                  itemBuilder: (context, index) {
                    final comment = wish.comments[index];
                    return _buildCommentTile(comment);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "اكتب تعليقًا...",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (text) async {
                        if (text.trim().isNotEmpty) {
                          final user = ref.read(userNotifierProvider).value;
                          if (user == null) return;
                          final newComment = Comment(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            wishId: wish.id,
                            userId: user.id,
                            userName: user.name,
                            text: text.trim(),
                            createdAt: DateTime.now(),
                          );
                          final updatedWish = wish.copyWith(
                            comments: [...wish.comments, newComment],
                          );
                          await ref
                              .read(wishNotifierProvider.notifier)
                              .updateWish(updatedWish);
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("تم إضافة التعليق!")),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    backgroundColor: AppColors.primary,
                    onPressed: () async {
                      if (commentController.text.trim().isNotEmpty) {
                        final user = ref.read(userNotifierProvider).value;
                        if (user == null) return;
                        final newComment = Comment(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          wishId: wish.id,
                          userId: user.id,
                          userName: user.name,
                          text: commentController.text.trim(),
                          createdAt: DateTime.now(),
                        );
                        final updatedWish = wish.copyWith(
                          comments: [...wish.comments, newComment],
                        );
                        await ref
                            .read(wishNotifierProvider.notifier)
                            .updateWish(updatedWish);
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم إضافة التعليق!")),
                        );
                      }
                    },
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // في كلا الملفين (EventDetailScreen و WishDetailScreen)، عدّل الدالة:

  Widget _buildContributorTile(Contribution contributor) {
    final user = ref.read(userNotifierProvider).value;
    // 👇 نبحث عن المستخدم في قاعدة البيانات (هنا نحتاج تعديل بسيط في HiveService لاحقًا)
    // لكن كحل سريع، نعرض الحرف الأول إذا لم يكن لدينا رابط صورة
    String? avatarUrl;
    // 👈 هنا يمكنك لاحقًا جلب المستخدم من HiveService للحصول على avatarUrl

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary20,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [

            CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl!)),

            CircleAvatar(
              backgroundColor: AppColors.primary10,
              radius: 16,
              child: Text(
                contributor.contributorName.characters.first,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contributor.contributorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${contributor.amount.toStringAsFixed(0)}\$",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimeAgo(contributor.contributedAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return Colors.green;
    if (percentage >= 75) return AppColors.primary10;
    if (percentage >= 50) return Colors.blue;
    if (percentage >= 25) return Colors.orange;
    return Colors.red;
  }

  String _formatTimeAgo(DateTime timestamp) {
    Duration difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return "الآن";
    if (difference.inMinutes < 60) return "${difference.inMinutes} دقيقة";
    if (difference.inHours < 24) return "${difference.inHours} ساعة";
    if (difference.inDays < 7) return "${difference.inDays} يوم";
    return "${difference.inDays ~/ 7} أسبوع";
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
                (c) =>
                    c.contributorId == ref.read(userNotifierProvider).value!.id,
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
                await ref
                    .read(wishNotifierProvider.notifier)
                    .updateWish(updatedWish);
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
