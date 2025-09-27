import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ⬅️ أضفنا هذا
import 'package:gift/screens/calendar_screen.dart';
import 'package:gift/screens/dashboard_screen.dart';
import 'package:gift/screens/events_screen.dart';
import 'package:gift/screens/notifications_screen.dart';
import 'package:gift/screens/profile_screen.dart';
import 'package:gift/screens/profile_settings_screen.dart';
import 'package:gift/screens/wish_list_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'Services/hive_service.dart';
import 'Services/notification_services.dart';
import 'constants/app_colors.dart';
//import 'providers.dart'; // ⬅️ أضفنا هذا

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  final hiveService = HiveService();
   await HiveService().init();
  await hiveService.addDummyData(); // 👈 👈 👈 أضف هذا السطر
  await NotificationService().init();
  runApp(
    ProviderScope( // ⬅️ أضفنا ProviderScope
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giftagon',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: 'Tajawal',
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const DashboardScreen(),
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const ProfileSettingsScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/events': (context) => const EventsScreen(),
        '/wish_list': (context) => const WishListScreen(),
      },
    );
  }
}