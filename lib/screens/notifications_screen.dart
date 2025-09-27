// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gift/screens/wish_detail_screen.dart';
import '../constants/app_colors.dart';
import '../models/hive/notification_model_hive.dart';
import '../providers.dart';
import 'event_detail_screen.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _selectedTab = 0;

  List<NotificationH> _getFilteredNotifications(List<NotificationH> notifications) {
    final sorted = List<NotificationH>.from(notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_selectedTab == 0) {
      return sorted;
    } else {
      return sorted.where((n) => !n.isRead).toList();
    }
  }

  Future<void> _markAllAsRead(WidgetRef ref) async {
    final notifications = ref.read(notificationNotifierProvider).value;
    if (notifications == null) return;

    for (var notification in notifications) {
      if (!notification.isRead) {
        final updated = notification.copyWith(isRead: true);
        await ref.read(notificationNotifierProvider.notifier).updateNotification(updated);
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم تحديد كل الإشعارات كمقروءة")),
    );
  }

  Future<void> _markAsRead(WidgetRef ref, NotificationH notification) async {
    final updated = notification.copyWith(isRead: true);
    await ref.read(notificationNotifierProvider.notifier).updateNotification(updated);
    setState(() {}); // لتحديث العرض البصري
  }

  Future<void> _deleteNotification(WidgetRef ref, String id) async {
    await ref.read(notificationNotifierProvider.notifier).deleteNotification(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم حذف الإشعار")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationNotifierProvider);

    return DefaultTabController(
      length: 2,
      initialIndex: _selectedTab,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                    (route) => false,
              );
            },
          ),
          title: Text(
            "الإشعارات",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: "الكل"),
              Tab(text: "غير المقروءة"),
            ],
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
          actions: [
            if (_selectedTab == 0)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextButton(
                  onPressed: () => _markAllAsRead(ref),
                  child: Text(
                    "تحديد الكل كمقروء",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
              data: (notifications) {
            final filtered = _getFilteredNotifications(notifications);
            if (filtered.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _buildNotificationTile(context, filtered[index], ref);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationH notification, WidgetRef ref) {
    Color getIconColor(String type) {
      switch (type) {
        case "comment":
          return Colors.blue;
        case "like":
          return Colors.red;
        case "contribution":
          return Colors.green;
        case "event":
          return AppColors.primary;
        default:
          return Colors.grey;
      }
    }

    IconData getIcon(String type) {
      switch (type) {
        case "comment":
          return Icons.comment;
        case "like":
          return Icons.favorite;
        case "contribution":
          return Icons.attach_money;
        case "event":
          return Icons.event;
        default:
          return Icons.notifications;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: notification.isRead ? Colors.white : AppColors.background,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getIconColor(notification.type),
          child: Icon(
            getIcon(notification.type),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            Text("من: ${notification.fromUserName}"),
            const SizedBox(height: 4),
            Text(
              _formatTimeAgo(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? const Icon(Icons.brightness_1, color: Colors.red, size: 12)
            : null,
        onTap: () async {
          if (!notification.isRead) {
            await _markAsRead(ref, notification);
          }
          if (notification.relatedId != null) {
            switch (notification.type) {
              case "contribution":
              case "like":
              case "comment":
                if (notification.relatedId!.contains("w")) { // افتراض أن معرف الهدية يبدأ بـ "w"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WishDetailScreen(wishId: notification.relatedId!),
                    ),
                  );
                } else if (notification.relatedId!.contains("e")) { // افتراض أن معرف الحدث يبدأ بـ "e"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(eventId: notification.relatedId!),
                    ),
                  );
                }
                break;
              case "event":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(eventId: notification.relatedId!),
                  ),
                );
                break;
            }
          }
          // 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆 👆

          // 👈 يمكنك لاحقًا إضافة منطق فتح الهدية أو الحدث المرتبط
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("فتحت: ${notification.message}")),
          );
        },
        onLongPress: () async {
          await _deleteNotification(ref, notification.id);
          if (!mounted) return;
          setState(() {}); // تحديث الواجهة
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _selectedTab == 0
                ? "لا توجد إشعارات"
                : "لا توجد إشعارات غير مقروءة",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
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