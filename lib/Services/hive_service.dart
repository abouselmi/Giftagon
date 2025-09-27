// lib/services/hive_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import '../models/comment_model.dart';
import '../models/contribution_model.dart';
import '../models/hive/notification_model_hive.dart';
import '../models/hive/user_model_hive.dart';
import '../models/hive/wish_model_hive.dart';
import '../models/hive/event_model_hive.dart';

class HiveService {
  List<UserH> getUsers() => _userBox.values.toList();
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  late Box<WishH> _wishesBox;
  late Box<EventH> _eventsBox;
  late Box<UserH> _userBox;
  late Box<Comment> _commentsBox;
  late Box<NotificationH> _notificationsBox;

  Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    }

    // ✅ 👇 تسجيل كل الـ Adapters هنا — بغض النظر عن النظام!
    Hive.registerAdapter(WishHAdapter());
    Hive.registerAdapter(EventHAdapter());
    Hive.registerAdapter(CommentAdapter());
    Hive.registerAdapter(UserHAdapter());
    Hive.registerAdapter(ContributionAdapter());
    Hive.registerAdapter(NotificationHAdapter()); // ⚠️ مهم! Contribution مفقود!

    // ✅ فتح الصناديق بعد التسجيل
    _wishesBox = await Hive.openBox<WishH>('wishes');
    _eventsBox = await Hive.openBox<EventH>('events');
    _userBox = await Hive.openBox<UserH>('user');
    _commentsBox = await Hive.openBox<Comment>('comments');
    _notificationsBox = await Hive.openBox<NotificationH>('notifications');
  }

  // 👇 الهدايا
  List<WishH> getWishes() => _wishesBox.values.toList();
  Future<void> addWish(WishH wish) => _wishesBox.put(wish.id, wish);
  Future<void> updateWish(WishH wish) => _wishesBox.put(wish.id, wish);
  Future<void> deleteWish(String id) => _wishesBox.delete(id);
  Future<void> addComment(Comment comment) =>
      _commentsBox.put(comment.id, comment);

  Future<WishH> getWishById(String id) async {
    final wish = _wishesBox.get(id);
    if (wish == null) {
      throw Exception("Event not found with ID: $id");
    }
    return wish;
  }

  // 👇 الأحداث
  List<EventH> getEvents() => _eventsBox.values.toList();
  Future<void> addEvent(EventH event) => _eventsBox.put(event.id, event);
  Future<void> updateEvent(EventH event) => _eventsBox.put(event.id, event);
  Future<void> deleteEvent(String id) => _eventsBox.delete(id);

  // 👇 👇 👇 أضف هذه الدالة الجديدة
  Future<EventH> getEventById(String id) async {
    final event = _eventsBox.get(id);
    if (event == null) {
      throw Exception("Event not found with ID: $id");
    }
    return event;
  }
  // 👇 دالة جلب كل الإشعارات
  // 👇 دوال الإشعارات

  List<NotificationH> getNotifications() =>
      _notificationsBox.values.toList(); // 👈 أضف هذه السطر
  Future<void> addNotification(NotificationH notification) =>
      _notificationsBox.put(notification.id, notification);
  Future<void> updateNotification(NotificationH notification) =>
      _notificationsBox.put(notification.id, notification);
  Future<void> deleteNotification(String id) => _notificationsBox.delete(id);

  // 👇 getter للـ Box — عشان نستخدمه في ValueListenableBuilder
  Box<NotificationH> get notificationsBox => _notificationsBox;

  Box<WishH> get wishesBox => _wishesBox;
  Box<EventH> get eventsBox => _eventsBox;

  Future<Comment> getCommentById(String id) async {
    final comment = _commentsBox.get(id);
    if (comment == null) {
      throw Exception("Comment not found with ID: $id");
    }
    return comment;
  }

  Future<void> deleteComment(String id) => _commentsBox.delete(id);
  Future<void> updateComment(Comment comment) =>
      _commentsBox.put(comment.id, comment);
  // 👇 دالة جلب التعليقات لهدية معينة
  List<Comment> getCommentsByWishId(String wishId) {
    return _commentsBox.values
        .where((comment) => comment.eventId == wishId)
        .toList();
  }

  // 👇 المستخدم
  UserH? getUser() => _userBox.values.isNotEmpty ? _userBox.values.first : null;

 // List<UserH> getUsers() => _userBox.values.toList();

  Future<void> deleteUser(String userId) async {
    await _userBox.delete(userId);
    // 👉 حذف جميع الهدايا والأحداث المرتبطة بهذا المستخدم
    final wishes = _wishesBox.values.where((w) => w.ownerId == userId).toList();
    for (var wish in wishes) {
      await deleteWish(wish.id);
    }
    final events = _eventsBox.values
        .where((e) => e.organizerId == userId)
        .toList();
    for (var event in events) {
      await deleteEvent(event.id);
    }
  }

  Future<void> saveUser(UserH user) => _userBox.put(user.id, user);

  // 👇 دالة لإضافة بيانات تجريبية — مرة واحدة فقط
  Future<void> addDummyData() async {
    if (_wishesBox.isEmpty) {
      final dummyWishes = [
        WishH(
          id: "w1",
          title: "آيفون 15 برو",
          description: "هدية عيد ميلادي من العائلة 🎁",
          imageUrl: null,
          targetAmount: 999.0,
          currentAmount: 650.0,
          currency: "USD",
          ownerId: "u123",
          ownerName: "خالد",
          circle: "family",
          isHidden: false,
          eventId: "e1",
          isFulfilled: false,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          deadline: DateTime.now().add(const Duration(days: 10)),
          contributors: [],
        ),
        WishH(
          id: "w2",
          title: "حقيبة سفر ذكية",
          description: "للرحلة إلى أوروبا هذا الصيف ✈️",
          imageUrl: null,
          targetAmount: 250.0,
          currentAmount: 250.0,
          currency: "USD",
          ownerId: "u124",
          ownerName: "نورا",
          circle: "friends",
          isHidden: true,
          eventId: null,
          isFulfilled: true,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          deadline: DateTime.now().subtract(const Duration(days: 1)),
          contributors: [],
        ),
        WishH(
          id: "w3",
          title: "سماعة Sony WH-1000XM5",
          description: "هدية لنفسي بعد التخرج 🎓",
          imageUrl: null,
          targetAmount: 350.0,
          currentAmount: 120.0,
          currency: "USD",
          ownerId: "u999", // 👈 مستخدم مختلف
          ownerName: "ليلى",
          circle: "friends",
          isHidden: false,
          eventId: null,
          isFulfilled: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          deadline: DateTime.now().add(const Duration(days: 20)),
          contributors: [],
        ),
        WishH(
          id: "w4",
          title: "حفل زفاف عمرو ونورا",
          description: "نساعدهم يجهزوا حفل الزفاف 💍",
          imageUrl: null,
          targetAmount: 2000.0,
          currentAmount: 800.0,
          currency: "USD",
          ownerId: "u888", // 👈 مستخدم مختلف
          ownerName: "عمرو",
          circle: "family",
          isHidden: false,
          eventId: null,
          isFulfilled: false,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          deadline: DateTime.now().add(const Duration(days: 30)),
          contributors: [],
        ),
      ];

      for (var wish in dummyWishes) {
        await addWish(wish);
      }
    }

    if (_eventsBox.isEmpty) {
      final dummyEvents = [
        EventH(
          id: "e2",
          title: "رحلة خيرية إلى المغرب",
          description: "جمع تبرعات لبناء مدرسة في الريف 🏫",
          organizerId: "u777", // 👈 مستخدم مختلف
          organizerName: "جمعية الخير",
          targetAmount: 5000.0,
          currentAmount: 1500.0,
          currency: "USD",
          wishId: null,
          contributors: [],
          isHidden: false,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          deadline: DateTime.now().add(const Duration(days: 45)),
          imageUrl: null,
        ),
        EventH(
          id: "e1",
          title: "🎉 هدية زفاف سارة وخالد",
          description: "نساعدهم يجهزوا بيتهم الجديد 🏡",
          organizerId: "u001",
          organizerName: "أم خالد",
          targetAmount: 5000.0,
          currentAmount: 3200.0,
          currency: "USD",
          wishId: "w1",
          contributors: [
            Contribution(
              contributorId: "u002",
              contributorName: "عم أحمد",
              amount: 500.0,
              contributedAt: DateTime.now().subtract(const Duration(days: 3)),
            ),
            Contribution(
              contributorId: "u003",
              contributorName: "خالتي فاطمة",
              amount: 1000.0,
              contributedAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
          isHidden: false,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          deadline: DateTime.now().add(const Duration(days: 14)),
          imageUrl: null,
        ),
      ];

      for (var event in dummyEvents) {
        await addEvent(event);
      }
    }

    /* if (_userBox.isEmpty) {
      final dummyUser = UserH(
        id: "u123",
        name: "Admin",
        email: "admin@example.com",
        age: 40,
        country: "palestine",
        isAdmin: true,
      );
      await saveUser(dummyUser);
    } */
    if (_userBox.isEmpty) {
      final dummyUser = UserH(
        id: "u125",
        name: "Admin",
        email: "abouselmi@example.com",
        age: 25,
        country: "palestine",
        isAdmin: true,
      );
      await saveUser(dummyUser);
    }
  }
}
