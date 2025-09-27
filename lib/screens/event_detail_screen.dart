// lib/screens/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/comment_model.dart';
import '../models/contribution_model.dart';
import '../models/hive/event_model_hive.dart';
import '../providers.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventNotifierProvider);

    return eventsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
         data:  (events) {
        final event = events.firstWhere((e) => e.id == widget.eventId);
        final user = ref.read(userNotifierProvider).value;
        if (user == null) {
          return Scaffold(
            body: Center(child: Text("خطأ: المستخدم غير مسجل")),
          );
        }

        final isOrganizer = event.organizerId == user.id;
        final isParticipant = event.contributors.any(
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
              "تفاصيل الحدث",
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
                // 👉 عنوان الحدث
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                // 👉 منظم الحدث
                Text(
                  "منظم الحدث: ${event.organizerName}",
                  style: TextStyle(
                    color: AppColors.primary10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // 👉 الوصف
                if (event.description != null)
                  Text(
                    event.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 16),
                // 👉 شريط التقدم
                LinearProgressIndicator(
                  value: event.progressPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  color: _getProgressColor(event.progressPercentage),
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 12,
                ),
                const SizedBox(height: 8),
                // 👉 المبلغ
                Text(
                  "${event.currency}${event.currentAmount.toStringAsFixed(0)} من ${event.currency}${event.targetAmount.toStringAsFixed(0)} (${event.progressPercentage.toStringAsFixed(0)}%)",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (!isParticipant && !isOrganizer)
                  OutlinedButton.icon(
                    onPressed: () {
                      _showContributionDialog(context, event, ref);
                    },
                    icon: const Icon(Icons.attach_money),
                    label: const Text("ساهم الآن"),
                  ),
                Row(
                  children: [
                    if (!isParticipant && !isOrganizer)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final updatedEvent = event.addContribution(
                            user.id,
                            user.name,
                            20.0,
                          );
                          await ref
                              .read(eventNotifierProvider.notifier)
                              .updateEvent(updatedEvent);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "ساهمت بـ \$20 في حدث: ${event.title}!",
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.attach_money),
                        label: const Text("ساهم الآن"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary10,
                        ),
                      ),
                    if (isParticipant && !isOrganizer)
                      OutlinedButton.icon(
                        onPressed: () {
                          _confirmWithdraw(context, event, ref);
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text("انسحب"),
                      ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showCommentsBottomSheet(context, event, ref);
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text("التعليقات"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 👉 قائمة المساهمين
                Text(
                  "المساهمون (${event.contributors.length})",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                ...event.contributors.map(
                      (contributor) => _buildContributorTile(contributor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showContributionDialog(BuildContext context, EventH event, WidgetRef ref) {
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
              subtitle: Text("\$${event.targetAmount}"),
              trailing: Radio<String>(
                value: "full",
                groupValue: "full",
                onChanged: (value) {
                  amountController.text = event.targetAmount.toString();
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
              final updatedEvent = event.addContribution(user.id, user.name, amount);
              await ref.read(eventNotifierProvider.notifier).updateEvent(updatedEvent);
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
        boxShadow: [BoxShadow(
          color: AppColors.primary20,
          blurRadius: 4,
          offset: const Offset(0, 2),)
        ]
      ),

      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary10,
            radius: 16,
            child: Text(
              comment.userId.characters.first,
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
      BuildContext context, EventH event, WidgetRef ref) {
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
                    "التعليقات (${event.comments.length})",
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
                  itemCount: event.comments.length,
                  itemBuilder: (context, index) {
                    final comment = event.comments[index];
                    return _buildCommentTile(comment);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
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
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            eventId: event.id,
                            userId: user.id,
                            userName: user.name,
                            text: text.trim(),
                            createdAt: DateTime.now(),
                          );
                          final updatedEvent = event.copyWith(
                            comments: [...event.comments, newComment],
                          );
                          await ref
                              .read(eventNotifierProvider.notifier)
                              .updateEvent(updatedEvent);
                          if (!mounted) return;
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
                      if (_commentController.text.trim().isNotEmpty) {
                        final user = ref.read(userNotifierProvider).value;
                        if (user == null) return;
                        final newComment = Comment(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          eventId: event.id,
                          userId: user.id,
                          userName: user.name,
                          text: _commentController.text.trim(),
                          createdAt: DateTime.now(),
                        );
                        final updatedEvent = event.copyWith(
                          comments: [...event.comments, newComment],
                        );
                        await ref
                            .read(eventNotifierProvider.notifier)
                            .updateEvent(updatedEvent);
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

  void _confirmWithdraw(
      BuildContext context, EventH event, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الانسحاب"),
        content: const Text(
          "هل أنت متأكد أنك تريد الانسحاب من هذا الحدث؟ سيتم خصم مساهمتك.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              final user = ref.read(userNotifierProvider).value;
              if (user == null) return;
              final updatedEvent = event.removeContribution(user.id);
              await ref
                  .read(eventNotifierProvider.notifier)
                  .updateEvent(updatedEvent);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم الانسحاب من الحدث وخصم المبلغ!"),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text("انسحب"),
          ),
        ],
      ),
    );
  }
}