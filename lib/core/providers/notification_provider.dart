import 'package:flutter/foundation.dart';
import '../services/notification_database_helper.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationDatabaseHelper _dbHelper = NotificationDatabaseHelper();
  List<LocalNotification> _notifications = [];
  int _unreadCount = 0;
  int? _currentUserId;

  List<LocalNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void init(int userId) {
    _currentUserId = userId;
    fetchNotifications();
  }

  Future<void> logDummyNotification(
    int userId,
    int productId,
    String productName,
  ) async {
    final notif = LocalNotification(
      userId: userId,
      title: 'Gimana meetup-nya kemarin?',
      body: 'Apakah barang "$productName" sudah laku terjual?',
      type: 'meetup_followup',
      payload: '{"product_id": $productId}',
      createdAt: DateTime.now(),
    );
    await _dbHelper.insertNotification(notif);
    if (_currentUserId == userId) {
      await fetchNotifications();
    }
  }

  Future<void> fetchNotifications() async {
    if (_currentUserId == null) return;
    try {
      _notifications = await _dbHelper.getNotifications(_currentUserId!);
      _unreadCount = await _dbHelper.getUnreadCount(_currentUserId!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetch notifications: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    await _dbHelper.markAsRead(id);
    await fetchNotifications();
  }

  Future<void> deleteNotification(int id) async {
    await _dbHelper.deleteNotification(id);
    await fetchNotifications();
  }
}
