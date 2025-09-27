// lib/providers.dart - النسخة المصححة
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'Services/hive_service.dart';
import 'models/hive/wish_model_hive.dart';
import 'models/hive/event_model_hive.dart';
import 'models/hive/user_model_hive.dart';
import 'models/hive/notification_model_hive.dart';

// 👇 Wish Provider - تم التصحيح
final wishNotifierProvider = StateNotifierProvider<WishNotifier, AsyncValue<List<WishH>>>((ref) {
  return WishNotifier(HiveService());
});

class WishNotifier extends StateNotifier<AsyncValue<List<WishH>>> {
  final HiveService _hiveService;
  WishNotifier(this._hiveService) : super(const AsyncValue.loading()) {
    loadWishes();
  }

  Future<void> loadWishes() async {
    try {
      state = const AsyncValue.loading();
      final wishes = _hiveService.getWishes();
      state = AsyncValue.data(wishes);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addWish(WishH wish) async {
    try {
      await _hiveService.addWish(wish);
      await loadWishes();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateWish(WishH wish) async {
    try {
      await _hiveService.updateWish(wish);
      await loadWishes();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteWish(String id) async {
    try {
      await _hiveService.deleteWish(id);
      await loadWishes();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

// 👇 Event Provider - تم التصحيح
final eventNotifierProvider = StateNotifierProvider<EventNotifier, AsyncValue<List<EventH>>>((ref) {
  return EventNotifier(HiveService());
});

class EventNotifier extends StateNotifier<AsyncValue<List<EventH>>> {
  final HiveService _hiveService;
  EventNotifier(this._hiveService) : super(const AsyncValue.loading()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      state = const AsyncValue.loading();
      final events = _hiveService.getEvents();
      state = AsyncValue.data(events);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addEvent(EventH event) async {
    try {
      await _hiveService.addEvent(event);
      await loadEvents();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateEvent(EventH event) async {
    try {
      await _hiveService.updateEvent(event);
      await loadEvents();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _hiveService.deleteEvent(id);
      await loadEvents();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

// 👇 User Provider - تم التصحيح
final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserH?>>((ref) {
  return UserNotifier(HiveService());
});

class UserNotifier extends StateNotifier<AsyncValue<UserH?>> {
  final HiveService _hiveService;
  UserNotifier(this._hiveService) : super(const AsyncValue.loading()) {
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      state = const AsyncValue.loading();
      final user = _hiveService.getUser();
      state = AsyncValue.data(user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> saveUser(UserH user) async {
    try {
      await _hiveService.saveUser(user);
      await loadUser();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

// 👇 Notification Provider - تم التصحيح
final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<List<NotificationH>>>((ref) {
  return NotificationNotifier(HiveService());
});

class NotificationNotifier extends StateNotifier<AsyncValue<List<NotificationH>>> {
  final HiveService _hiveService;
  NotificationNotifier(this._hiveService) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      final notifications = _hiveService.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addNotification(NotificationH notification) async {
    try {
      await _hiveService.addNotification(notification);
      await loadNotifications();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateNotification(NotificationH notification) async {
    try {
      await _hiveService.updateNotification(notification);
      await loadNotifications();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _hiveService.deleteNotification(id);
      await loadNotifications();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

// 👇 User List Provider - تم التصحيح
final userListNotifierProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<UserH>>>((ref) {
  return UserListNotifier(HiveService());
});

class UserListNotifier extends StateNotifier<AsyncValue<List<UserH>>> {
  final HiveService _hiveService;
  UserListNotifier(this._hiveService) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = _hiveService.getUsers();
      state = AsyncValue.data(users);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _hiveService.deleteUser(userId);
      await loadUsers();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}