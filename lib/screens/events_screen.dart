// lib/screens/events_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/hive/event_model_hive.dart';
import '../providers.dart';
import 'add_event_form_screen.dart';
import 'event_detail_screen.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;
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
              "الأحداث الجماعية",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            actions: [
              if (!isMobile) // 👈 زر الإضافة يظهر فقط في الويب/المكتب
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEventFormScreen(),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: ref.watch(eventNotifierProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "لا توجد أحداث جماعية بعد",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddEventFormScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("أضف حدثًا جديدًا"),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(context, event, isMobile);
                },
              );
            },
          ),
          // 👇 زر الإضافة في الموبايل — في الـ FAB
          floatingActionButton: isMobile
              ? FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEventFormScreen(),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          )
              : null,
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, EventH event, bool isMobile) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary10,
          child: Icon(Icons.event, color: AppColors.primary),
        ),
        title: Text(event.title),
        subtitle: Text("منظم: ${event.organizerName} • ${event.deadline?.day}/${event.deadline?.month}"),
        trailing: Text(
          "${event.progressPercentage.toStringAsFixed(0)}%",
          style: TextStyle(
            color: _getProgressColor(event.progressPercentage),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: event.id),
            ),
          );
        },
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
}