// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/app_colors.dart';
import '../models/hive/event_model_hive.dart';
import '../models/hive/wish_model_hive.dart';
import '../providers.dart';
import 'event_detail_screen.dart';
import 'wish_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;
    _calendarFormat = CalendarFormat.month;
  }

  // 👇 دالة لتحديد ما إذا كان اليوم يحتوي على أحداث أو هدايا
  List<DateTime> _getHighlightedDays(List<EventH> events, List<WishH> wishes) {
    Set<DateTime> dates = {};
    for (var event in events) {
      if (event.deadline != null) {
        dates.add(DateTime(
          event.deadline!.year,
          event.deadline!.month,
          event.deadline!.day,
        ));
      }
    }
    for (var wish in wishes) {
      if (wish.deadline != null) {
        dates.add(DateTime(
          wish.deadline!.year,
          wish.deadline!.month,
          wish.deadline!.day,
        ));
      }
    }
    return dates.toList();
  }

  // 👇 دالة لعرض البطاقة عند اختيار يوم
  Widget _buildDayDetails(
      BuildContext context,
      List<EventH> events,
      List<WishH> wishes,
      DateTime day,
      ) {
    final eventsToday = events.where((e) => _isSameDay(e.deadline, day)).toList();
    final wishesToday = wishes.where((w) => _isSameDay(w.deadline, day)).toList();

    if (eventsToday.isEmpty && wishesToday.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اليوم: ${day.day}/${day.month}/${day.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            if (eventsToday.isNotEmpty) ...[
              const Text(
                'الأحداث',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              ...eventsToday.map((event) => _buildEventItem(context, event)),
              const SizedBox(height: 16),
            ],
            if (wishesToday.isNotEmpty) ...[
              const Text(
                'الهدايا',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ...wishesToday.map((wish) => _buildWishItem(context, wish)),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildEventItem(BuildContext context, EventH event) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event, color: Colors.blue, size: 20),
      title: Text(event.title, style: const TextStyle(fontSize: 14)),
      trailing: Text(
        '${event.progressPercentage.toInt()}%',
        style: TextStyle(color: _getProgressColor(event.progressPercentage)),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventId: event.id),
          ),
        );
      },
    );
  }

  Widget _buildWishItem(BuildContext context, WishH wish) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.card_giftcard, color: Colors.green, size: 20),
      title: Text(wish.title, style: const TextStyle(fontSize: 14)),
      trailing: Text(
        '${wish.progressPercentage.toInt()}%',
        style: TextStyle(color: _getProgressColor(wish.progressPercentage)),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WishDetailScreen(wishId: wish.id),
          ),
        );
      },
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return Colors.green;
    if (percentage >= 75) return AppColors.primary;
    if (percentage >= 50) return Colors.blue;
    if (percentage >= 25) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventNotifierProvider);
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
          "التقويم",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.month: 'شهر',
              CalendarFormat.week: 'أسبوع',
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonTextStyle: const TextStyle(color: AppColors.primary),
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: AppColors.primary),
              todayDecoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              // 👇 تلوين الأيام المهمة
              defaultTextStyle: const TextStyle(color: Colors.black87),
            ),
            // 👇 إضافة المؤشرات البصرية
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                return eventsAsync.when(
                  loading: () => null,
                  error: (err, stack) => null,
                  data: (eventList) {
                    return wishesAsync.when(
                      loading: () => null,
                      error: (err, stack) => null,
                      data: (wishList) {
                        final hasEvent = eventList.any((e) => _isSameDay(e.deadline, day));
                        final hasWish = wishList.any((w) => _isSameDay(w.deadline, day));
                        if (hasEvent || hasWish) {
                          return Positioned(
                            bottom: 2,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (hasEvent)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (hasWish)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 2),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }
                        return null;
                      },
                    );
                  },
                );
              },
            ),
          ),
          // 👇 عرض تفاصيل اليوم المحدد
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (events) {
                return wishesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (wishes) {
                    return _buildDayDetails(context, events, wishes, _selectedDay);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}