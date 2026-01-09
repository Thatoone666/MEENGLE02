import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/firebase_notification_service.dart';
import '../services/socket_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();
  final SocketService _socketService = SocketService();

  final List<Map<String, dynamic>> _notifications = [];
  bool _isInitialized = false;
  String? _fcmToken;
  StreamSubscription? _notificationSubscription;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  Future<void> initialize(String userId) async {
    try {
      await _notificationService.initialize();
      _fcmToken = _notificationService.fcmToken;

      // Send FCM token to backend via Socket.io
      if (_fcmToken != null) {
        _socketService.socket?.emit('registerFCMToken', {
          'userId': userId,
          'fcmToken': _fcmToken,
        });
      }

      // Listen to incoming notifications
      _notificationSubscription =
          _notificationService.notifications.listen((notification) {
        _notifications.insert(0, notification);
        notifyListeners();

        // Handle specific notification types
        _handleNotificationAction(notification);
      });

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>?;
    if (data == null) return;

    final action = data['action'] as String?;

    switch (action) {
      case 'open_story':
        // Navigate to story
        debugPrint('Open story: ${data['storyId']}');
        break;
      case 'open_chat':
        // Navigate to chat
        debugPrint('Open chat: ${data['matchId']}');
        break;
      case 'open_matches':
        // Navigate to matches
        debugPrint('Open matches');
        break;
      case 'open_spotlight':
        // Navigate to spotlight
        debugPrint('Open spotlight');
        break;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationService.dispose();
    super.dispose();
  }
}
