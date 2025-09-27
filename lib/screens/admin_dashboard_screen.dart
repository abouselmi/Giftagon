// lib/screens/admin_dashboard_screen.dart - النسخة المصححة
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/hive/wish_model_hive.dart';
import '../models/hive/event_model_hive.dart';
import '../models/hive/user_model_hive.dart';
import '../providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
      data: (user) {
        if (user == null || !user.isAdmin) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.admin_panel_settings, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "ليس لديك صلاحية الوصول إلى لوحة التحكم",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final wishesAsync = ref.watch(wishNotifierProvider);
        final eventsAsync = ref.watch(eventNotifierProvider);
        final usersAsync = ref.watch(userListNotifierProvider);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("لوحة التحكم الإدارية"),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👉 الإحصائيات
                _buildStatsCard(wishesAsync, eventsAsync, usersAsync),
                const SizedBox(height: 24),

                // 👉 إدارة الهدايا
                _buildSectionHeader("الهدايا"),
                _buildWishesSection(wishesAsync, context, ref),

                const SizedBox(height: 24),

                // 👉 إدارة الأحداث
                _buildSectionHeader("الأحداث"),
                _buildEventsSection(eventsAsync, context, ref),

                const SizedBox(height: 24),

                // 👉 إدارة المستخدمين
                _buildSectionHeader("المستخدمون"),
                _buildUsersSection(usersAsync, context, ref),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(
      AsyncValue<List<WishH>> wishes,
      AsyncValue<List<EventH>> events,
      AsyncValue<List<UserH>> users,
      ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "الإحصائيات",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            wishes.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (wishList) => events.when(
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
                data: (eventList) => users.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                  data: (userList) {
                    final totalWishes = wishList.length;
                    final totalEvents = eventList.length;
                    final totalUsers = userList.length;
                    final totalAmount = (wishList.fold(0.0, (sum, wish) => sum + (wish.currentAmount))) +
                        (eventList.fold(0.0, (sum, event) => sum + (event.currentAmount)));

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildStatItem("الهدايا", totalWishes.toString(), Icons.card_giftcard),
                        _buildStatItem("الأحداث", totalEvents.toString(), Icons.event),
                        _buildStatItem("المستخدمون", totalUsers.toString(), Icons.people),
                        _buildStatItem("المبلغ الكلي", "\$${totalAmount.toStringAsFixed(0)}", Icons.attach_money),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildWishesSection(AsyncValue<List<WishH>> wishesAsync, BuildContext context, WidgetRef ref) {
    return wishesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text("خطأ: $err"),
      data: (wishes) {
        final count = wishes.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("العدد: $count", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildWishesList(context, ref, wishes),
          ],
        );
      },
    );
  }

  Widget _buildEventsSection(AsyncValue<List<EventH>> eventsAsync, BuildContext context, WidgetRef ref) {
    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text("خطأ: $err"),
      data: (events) {
        final count = events.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("العدد: $count", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildEventsList(context, ref, events),
          ],
        );
      },
    );
  }

  Widget _buildUsersSection(AsyncValue<List<UserH>> usersAsync, BuildContext context, WidgetRef ref) {
    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text("خطأ: $err"),
      data: (users) {
        final count = users.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("العدد: $count", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildUsersList(context, ref, users),
          ],
        );
      },
    );
  }

  Widget _buildWishesList(BuildContext context, WidgetRef ref, List<WishH> wishes) {
    if (wishes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("لا توجد هدايا"),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: wishes.length,
      itemBuilder: (context, index) {
        final wish = wishes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(wish.title),
            subtitle: Text("طلبها: ${wish.ownerName} • ${(wish.progressPercentage).toInt()}%"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteWish(context, ref, wish.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList(BuildContext context, WidgetRef ref, List<EventH> events) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("لا توجد أحداث"),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(event.title),
            subtitle: Text("منظم: ${event.organizerName} • ${(event.progressPercentage).toInt()}%"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteEvent(context, ref, event.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersList(BuildContext context, WidgetRef ref, List<UserH> users) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("لا يوجد مستخدمون"),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!user.isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteUser(context, ref, user.id),
                  ),
                if (user.isAdmin)
                  const Icon(Icons.admin_panel_settings, color: Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteWish(BuildContext context, WidgetRef ref, String wishId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذه الهدية؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(wishNotifierProvider.notifier).deleteWish(wishId);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حذف الهدية")));
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvent(BuildContext context, WidgetRef ref, String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذا الحدث؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(eventNotifierProvider.notifier).deleteEvent(eventId);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حذف الحدث")));
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذا المستخدم؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(userListNotifierProvider.notifier).deleteUser(userId);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حذف المستخدم")));
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}