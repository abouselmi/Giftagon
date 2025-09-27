// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gift/screens/profile_settings_screen.dart';
import 'package:gift/utils/utils.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/hive/wish_model_hive.dart';
import '../models/hive/event_model_hive.dart';
import '../providers.dart';
import '../widgets/sidebar_icon_button.dart';
import '../widgets/custom_wish_card.dart';
import 'add_wish_form.dart';
import 'add_event_form_screen.dart';
import 'admin_dashboard_screen.dart';
import 'calendar_screen.dart';
import 'events_screen.dart';
import 'event_detail_screen.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;
        return Scaffold(
          body: isMobile
              ? _buildMobileLayout(context, ref)
              : _buildDesktopLayout(context, ref),
          bottomNavigationBar: isMobile ? _buildBottomNavBar(context,ref) : null,
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        _buildHeader(context, ref, isMobile: true),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildGiftListSection(context, ref, isMobile: true),
              const SizedBox(height: 24),
              _buildComingEventsSection(context, ref, isMobile: true),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildSidebar(context, ref, isMobile: false), // 👈 مرر ref
               Expanded(
          child: CustomScrollView(
            slivers: [
              _buildHeader(context, ref, isMobile: false),
              SliverPadding(
                padding: const EdgeInsets.all(32),
                sliver: SliverFillRemaining(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildGiftListSection(context, ref, isMobile: false),
                      ),
                      const SizedBox(width: 32),
                      SizedBox(
                        width: 320,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildComingEventsSection(context, ref, isMobile: false),
                              const SizedBox(height: 24),
                              _buildTopGiftsSection(context, ref, isMobile: false),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, {required bool isMobile}) {
    final user = ref.watch(userNotifierProvider).value;
    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      elevation: 0,
      title: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Giftagon',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B2A33),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Add , Track , Participate',
                style: TextStyle(fontSize: 12, color: Color(0xFF7B7B7B)),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 0, width: isMobile ? 0 : 24),
          SizedBox(
            width: isMobile ? double.infinity : 200,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9999),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: Color(0xFF7B7B7B), fontSize: 14),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 0, width: isMobile ? 0 : 24),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary10,
                  backgroundImage: user?.avatarUrl != null
                      ? getImageProvider(user!.avatarUrl!) // 👈 يعرض الصورة المعدلة
                      : null,
                  child: user?.avatarUrl == null
                      ? const Icon(Icons.person, color: AppColors.primary, size: 24)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  user?.name ?? 'Abou Selmi',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1B2A33),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftListSection(BuildContext context, WidgetRef ref, {required bool isMobile}) {
    final wishesAsync = ref.watch(wishNotifierProvider);
    return wishesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (wishes) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateTime.now().year}\n${DateFormat('MMMM', 'ar').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: isMobile ? 36 : 48,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2A33),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              ...wishes.map((wish) {
                return Padding(
                  key: ValueKey(wish.id),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CustomWishCard(
                    wish: wish,
                    onEditPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWishFormScreen(initialWish: wish),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddWishFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add New Gift'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B3E8C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComingEventsSection(BuildContext context, WidgetRef ref, {required bool isMobile}) {
    final eventsAsync = ref.watch(eventNotifierProvider);
    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (events) {
        return Container(
          height: isMobile ? null : 480,
          decoration: BoxDecoration(
            color: const Color(0xFFFDE9ED),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF96CA2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    'Coming Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...events.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildEventListItem(context, event, ref),
                );
              }),
              const SizedBox(height: 16),
              if (!isMobile)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEventFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add New Event'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B3E8C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventListItem(BuildContext context, EventH event, WidgetRef ref) {
    final user = ref.read(userNotifierProvider).value;
    final isOrganizer = event.organizerId == user?.id;
    final isParticipant = event.contributors.any((c) => c.contributorId == user?.id);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventId: event.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: getImageProvider(event.imageUrl), // 👈 يعرض الصورة
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.organizerName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2AB8E6),
                        ),
                      ),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDate(event.deadline),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${event.progressPercentage.toInt()}%',
                  style: TextStyle(
                    color: _getProgressColor(event.progressPercentage),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 👇 زر المساهمة — يظهر فقط إذا كنت مؤهلاً
            if (!isParticipant && !isOrganizer && user != null)
              ElevatedButton.icon(
                onPressed: () {
                  _showContributionDialog(context, event, ref, isEvent: true);
                },
                icon: const Icon(Icons.attach_money, size: 16),
                label: const Text("ساهم الآن", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary10,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGiftsSection(BuildContext context, WidgetRef ref, {required bool isMobile}) {
    final wishesAsync = ref.watch(wishNotifierProvider);
    return wishesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (wishes) {
        final user = ref.read(userNotifierProvider).value;
        if (user == null) return const SizedBox.shrink();
        final friendsGifts = wishes.where((wish) => wish.ownerId != user.id).toList();
        friendsGifts.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
        final topGifts = friendsGifts.take(5).toList();
        if (topGifts.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          height: isMobile ? null : 320,
          decoration: BoxDecoration(
            color: const Color(0xFFFDE9ED),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF96CA2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      'Friend\'s Top Gifts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...topGifts.map((wish) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTopGiftItem(context, wish, ref),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopGiftItem(BuildContext context, WishH wish, WidgetRef ref) {
    final user = ref.read(userNotifierProvider).value;
    final isOwner = wish.ownerId == user?.id;
    final isParticipant = wish.contributors.any((c) => c.contributorId == user?.id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: getImageProvider(wish.imageUrl), // 👈 يعرض الصورة
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wish.ownerName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2AB8E6),
                      ),
                    ),
                    Text(
                      wish.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2A33),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${wish.progressPercentage.toInt()}%',
                style: TextStyle(
                  color: _getProgressColor(wish.progressPercentage),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 👇 زر المساهمة — يظهر فقط إذا كنت مؤهلاً
          if (!isParticipant && !isOwner && user != null)
            ElevatedButton.icon(
              onPressed: () {
                _showContributionDialog(context, wish, ref, isEvent: false);
              },
              icon: const Icon(Icons.attach_money, size: 16),
              label: const Text("ساهم الآن", style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary10,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  void _showContributionDialog(
      BuildContext context,
      dynamic item,
      WidgetRef ref, {
        bool isEvent = false,
      }) {
    final TextEditingController amountController = TextEditingController(text: "20.0");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ساهم في الهدية"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              final amount = double.tryParse(amountController.text) ?? 20.0;
              if (amount <= 0) return;
              final user = ref.read(userNotifierProvider).value!;
              if (isEvent) {
                final updatedEvent = (item as EventH).addContribution(user.id, user.name, amount);
                await ref.read(eventNotifierProvider.notifier).updateEvent(updatedEvent);
              } else {
                final updatedWish = (item as WishH).addContribution(user.id, user.name, amount);
                await ref.read(wishNotifierProvider.notifier).updateWish(updatedWish);
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ساهمت بـ \$${amount.toStringAsFixed(2)}!")),
              );
            },
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return Colors.green;
    if (percentage >= 75) return AppColors.primary;
    if (percentage >= 50) return Colors.blue;
    if (percentage >= 25) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "لا يوجد";
    return "${date.day}-${date.month}-${date.year}";
  }

  // 👇 Bottom Navigation Bar — للموبايل فقط
  Widget _buildBottomNavBar(BuildContext context,WidgetRef ref) {
    final user = ref.watch(userNotifierProvider).value; // 👈 أضف هذا السطر
    return BottomNavigationBar(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
        BottomNavigationBarItem(icon: Icon(Icons.cake), label: "الأحداث"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "التقويم"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        // 👇 زر الإدارة — يظهر فقط للمشرفين
        if (user?.isAdmin == true)
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: "الإدارة",
          ),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: "تسجيل الخروج"),
      ],
      onTap: (index) {
        int actualIndex = index;
        if (user?.isAdmin == true) {
          // إذا كان المشرف — عدد العناصر 6
          switch (actualIndex) {
            case 0: Navigator.pushReplacementNamed(context, '/profile'); break;
            case 1: Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsScreen())); break;
            case 2: Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen())); break;
            case 3: Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen())); break;
            case 4: Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen())); break;
            case 5:
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تسجيل الخروج")));
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              break;
          }
        } else {
          // إذا كان مستخدم عادي — عدد العناصر 5
          switch (actualIndex) {
            case 0: Navigator.pushReplacementNamed(context, '/profile'); break;
            case 1: Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsScreen())); break;
            case 2: Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen())); break;
            case 3: Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen())); break;
            case 4:
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تسجيل الخروج")));
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              break;
          }
        }
      },
    );
  }
  // 👇 Sidebar — للويب فقط
  Widget _buildSidebar(BuildContext context,WidgetRef ref, {required bool isMobile}) {
    final user = ref.watch(userNotifierProvider).value; // 👈 الآن معرف
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF5B3E8C),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/LogoWhite.png',
              width: 40,
              height: 50,
              fit: BoxFit.contain,
              semanticLabel: 'Giftagon logo',
            ),
            const SizedBox(height: 24),
            SidebarIconButton(
              icon: Icons.home,
              color: const Color(0xFFA88FE0),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
              semanticLabel: 'Home',
            ),
            const SizedBox(height: 24),
            SidebarIconButton(
              icon: Icons.cake,
              color: Colors.white,
              backgroundColor: const Color(0xFF7E5FC1),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsScreen()));
              },
              semanticLabel: 'Birthday',
            ),
            const SizedBox(height: 24),
            SidebarIconButton(
              icon: Icons.calendar_today,
              color: const Color(0xFFA88FE0),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen()));
              },
              semanticLabel: 'Calendar',
            ),
            const SizedBox(height: 24),
            SidebarIconButton(
              icon: Icons.settings,
              color: const Color(0xFFA88FE0),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
                );
              },
              semanticLabel: 'Settings',
            ),
            const Spacer(),
            if (user?.isAdmin == true) // 👈 يظهر فقط للمشرفين
              SidebarIconButton(
                icon: Icons.admin_panel_settings,
                color: const Color(0xFFA88FE0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  );
                },
                semanticLabel: 'Admin Dashboard',
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تسجيل الخروج")));
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinky,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                fixedSize: const Size(72, 72),
                elevation: 8,
                shadowColor: AppColors.eventsBackground,
                padding: EdgeInsets.zero,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout, size: 24, color: Colors.white),
                  SizedBox(height: 4),
                  Text('Logout', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}