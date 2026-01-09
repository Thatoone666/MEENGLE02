import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

/// Real-time notifications service with Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  late FirebaseMessaging _messaging;
  late FlutterLocalNotificationsPlugin _localNotifications;
  
  final _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
  
  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialize notifications
  Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Request permission
    await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carryForward: true,
      critical: true,
      provisional: true,
      sound: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Get initial message if app was terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    // Subscribe to topics
    await subscribeToPushTopics();
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    
    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'Meengle',
      body: message.notification?.body ?? '',
      payload: data,
    );

    // Emit to stream
    _notificationStreamController.add(data);
  }

  /// Handle background message tap
  void _handleBackgroundMessage(RemoteMessage message) {
    final data = message.data;
    _notificationStreamController.add(data);
    // Navigate based on notification type
    _handleNotificationNavigation(data);
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'meengle_channel',
      'Meengle Notifications',
      channelDescription: 'Notifications for Meengle',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      payload.hashCode,
      title,
      body,
      details,
      payload: jsonEncode(payload),
    );
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'new_match':
        // Navigate to matches screen
        break;
      case 'new_message':
        // Navigate to chat screen
        break;
      case 'moment_match':
        // Navigate to moments screen
        break;
      case 'moment_expiring':
        // Show moment expiring alert
        break;
      case 'circle_activity':
        // Navigate to circles screen
        break;
      default:
        break;
    }
  }

  /// Subscribe to push notification topics
  Future<void> subscribeToPushTopics() async {
    await Future.wait([
      _messaging.subscribeToTopic('all_users'),
      _messaging.subscribeToTopic('verified_users'),
      _messaging.subscribeToTopic('premium_users'),
    ]);
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  /// Get notification stream
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController.stream;

  /// Send local notification
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: {'imageUrl': imageUrl ?? ''},
    );
  }

  /// Subscribe to user topic
  Future<void> subscribeToUserTopic(String userId) async {
    await _messaging.subscribeToTopic('user_$userId');
  }

  /// Unsubscribe from user topic
  Future<void> unsubscribeFromUserTopic(String userId) async {
    await _messaging.unsubscribeFromTopic('user_$userId');
  }

  /// Dispose
  void dispose() {
    _notificationStreamController.close();
  }
}

import 'dart:convert';
