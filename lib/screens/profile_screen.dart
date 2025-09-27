// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/comment_model.dart';
import '../models/hive/wish_model_hive.dart';
import '../models/hive/user_model_hive.dart';
import '../providers.dart';
import '../utils/utils.dart';
import 'notifications_screen.dart';
import 'profile_settings_screen.dart';
import 'wish_detail_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _filter = "all";

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userNotifierProvider);
    final wishesAsync = ref.watch(wishNotifierProvider);

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
          "ملفي الشخصي",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(userAsync),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "أهدائي ومشاركاتي",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        value: "upcoming_surprises",
                        child: Text("مفاجآت قريبة"),
                      ),
                      DropdownMenuItem(
                        value: "ongoing_events",
                        child: Text("أحداث جارية"),
                      ),
                      DropdownMenuItem(
                        value: "recently_gifted",
                        child: Text("أهدى مؤخرًا"),
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
            const SizedBox(height: 16),
            wishesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
                 data: (wishes) {
                final user = userAsync.value;
                if (user == null) return const SizedBox.shrink();
                final filteredWishes = _getFilteredWishes(wishes, user);
                return Column(
                  children: filteredWishes.map((wish) {
                    return _buildWishCard(context, wish, user);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<WishH> _getFilteredWishes(List<WishH> wishes, UserH user) {
    final userWishes = wishes.where((wish) {
      return wish.ownerId == user.id ||
          wish.contributors.any((c) => c.contributorId == user.id);
    }).toList();

    if (_filter == "all") return userWishes;
    if (_filter == "upcoming_surprises") {
      return userWishes
          .where((wish) =>
      wish.isHidden &&
          wish.deadline != null &&
          wish.deadline!.isAfter(DateTime.now()))
          .toList();
    }
    if (_filter == "ongoing_events") {
      return userWishes.where((wish) => wish.eventId != null).toList();
    }
    if (_filter == "recently_gifted") {
      return userWishes.where((wish) => wish.isFulfilled).toList();
    }
    return userWishes;
  }

  Widget _buildProfileHeader(AsyncValue<UserH?> userAsync) {
    return userAsync.when(
      loading: () => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary10,
              child: const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
      error: (err, stack) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Text('Error: $err'),
      ),
         data: (user) {
        final userName = user?.name ?? "مستخدم";
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary10,
                backgroundImage: user?.avatarUrl != null
                    ? getImageProvider(user!.avatarUrl) // 👈 هنا
                    : const AssetImage('assets/images/avatar.png'),
                child: user?.avatarUrl == null
                    ? Icon(Icons.person, color: AppColors.primary, size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "🌟 مستخدم نشط",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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

  Widget _buildWishCard(BuildContext context, WishH wish, UserH user) {
    if (wish.isHidden && wish.ownerId != user.id) {
      return const SizedBox.shrink();
    }

    Color getProgressColor(double percentage) {
      if (percentage >= 100) return Colors.green;
      if (percentage >= 75) return AppColors.primary;
      if (percentage >= 50) return Colors.blue;
      if (percentage >= 25) return Colors.orange;
      return Colors.red;
    }

    return InkWell(
      key: ValueKey(wish.id),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WishDetailScreen(wishId: wish.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (wish.ownerId == user.id)
                    const Icon(Icons.card_giftcard, color: AppColors.primary),
                  if (wish.ownerId != user.id)
                    const Icon(Icons.group, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      wish.ownerId == user.id
                          ? "هدية طلبتها: ${wish.title}"
                          : "شاركت في هدية لـ ${wish.ownerName}: ${wish.title}",
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: wish.progressPercentage / 100,
                backgroundColor: Colors.grey[200],
                color: getProgressColor(wish.progressPercentage),
                borderRadius: BorderRadius.circular(8),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                "${wish.currency}${wish.currentAmount.toStringAsFixed(0)} من ${wish.currency}${wish.targetAmount.toStringAsFixed(0)} (${wish.progressPercentage.toStringAsFixed(0)}%)",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              if (wish.description != null)
                Text(
                  wish.description!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                Text(
                  "تم إنشاؤها في: ${wish.createdAt.day}/${wish.createdAt.month}/${wish.createdAt.year}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final userName = user.name;
                      final updatedWish = wish.addContribution(
                        user.id,
                        userName,
                        1.0,
                      );
                      await ref.read(wishNotifierProvider.notifier).updateWish(updatedWish);
                      if (!mounted) return; // ✅ تم الإصلاح
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تم الإعجاب بالهدية!")),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: wish.contributors.any(
                                (c) => c.contributorId == user.id,
                          )
                              ? Colors.red
                              : Colors.grey,
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
                  GestureDetector(
                    onTap: () {
                      _showCommentsBottomSheet(context, wish, user);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.comment, color: Colors.grey, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "${wish.comments.length}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
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
              if (wish.isHidden)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.visibility_off,
                        size: 16,
                        color: Colors.purple,
                      ),
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

  void _showCommentsBottomSheet(BuildContext context, WishH wish, UserH user) {
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
                          final userName = user.name;
                          final newComment = Comment(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: user.id,
                            userName: userName,
                            text: text.trim(),
                            createdAt: DateTime.now(),
                            wishId: wish.id,
                            eventId: null,
                          );
                          await ref.read(wishNotifierProvider.notifier).updateWish(
                            wish.copyWith(
                              comments: [...wish.comments, newComment],
                            ),
                          );
                          if (!mounted) return; // ✅ تم الإصلاح
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("تم إضافة التعليق!"),
                            ),
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
                        final userName = user.name;
                        final newComment = Comment(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: user.id,
                          userName: userName,
                          text: commentController.text.trim(),
                          createdAt: DateTime.now(),
                          wishId: wish.id,
                          eventId: null,
                        );
                        await ref.read(wishNotifierProvider.notifier).updateWish(
                          wish.copyWith(
                            comments: [...wish.comments, newComment],
                          ),
                        );
                        if (!mounted) return; // ✅ تم الإصلاح
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

  Widget _buildCommentTile(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                child: Text(comment.userName.characters.first),
              ),
              const SizedBox(width: 8),
              Text(
                comment.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(comment.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment.text),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    Duration difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return "الآن";
    if (difference.inMinutes < 60) return "${difference.inMinutes} دقيقة";
    if (difference.inHours < 24) return "${difference.inHours} ساعة";
    if (difference.inDays < 7) return "${difference.inDays} يوم";
    return "${difference.inDays ~/ 7} أسبوع";
  }
}