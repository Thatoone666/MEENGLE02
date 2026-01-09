import 'dart:async';

import 'socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// A lightweight fake socket service for tests. It exposes the same streams
/// and methods used by the real `SocketService` but allows tests to push
/// events programmatically.
class FakeSocketService implements SocketService {
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _historyController = StreamController<List<dynamic>>.broadcast();
  final _typingController = StreamController<String>.broadcast();
  final _messageEditedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeletedController = StreamController<String>.broadcast();
  final _onlineStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _readController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageReactedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _momentNotificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _noteNotificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _storyNotificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _matchNotificationController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  @override
  Stream<List<dynamic>> get history => _historyController.stream;

  @override
  Stream<String> get typing => _typingController.stream;

  @override
  Stream<Map<String, dynamic>> get messageEdited =>
      _messageEditedController.stream;

  @override
  Stream<String> get messageDeleted => _messageDeletedController.stream;

  @override
  Stream<Map<String, dynamic>> get onlineStatus =>
      _onlineStatusController.stream;

  @override
  Stream<Map<String, dynamic>> get read => _readController.stream;

  @override
  Stream<Map<String, dynamic>> get messageReacted =>
      _messageReactedController.stream;

  @override
  Stream<Map<String, dynamic>> get momentNotifications => _momentNotificationController.stream;

  @override
  Stream<Map<String, dynamic>> get noteNotifications => _noteNotificationController.stream;

  @override
  Stream<Map<String, dynamic>> get storyNotifications => _storyNotificationController.stream;

  @override
  Stream<Map<String, dynamic>> get matchNotifications => _matchNotificationController.stream;

  @override
  io.Socket? socket;

  bool connected = false;

  // Methods to simulate incoming events
  void pushHistory(List<dynamic> items) => _historyController.add(items);
  void pushMessage(Map<String, dynamic> msg) => _messageController.add(msg);
  void pushTyping(String from) => _typingController.add(from);
  void pushMessageEdited(Map<String, dynamic> msg) =>
      _messageEditedController.add(msg);
  void pushMessageDeleted(String id) => _messageDeletedController.add(id);
  void pushOnlineStatus(Map<String, dynamic> status) =>
      _onlineStatusController.add(status);

  @override
  void connect({required String userId, required String matchId}) {
    connected = true;
  }

  @override
  void disconnect() {
    connected = false;
  }

  @override
  void sendMessage(
      {required String from,
      required String to,
      required String text,
      String? replyTo}) {
    // Echo the message back as if server sent it
    pushMessage({
      'from': from,
      'to': to,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
      'replyTo': replyTo
    });
  }

  @override
  void sendTyping({required String from, required String to}) {
    pushTyping(from);
  }

  @override
  void sendRead({required String from, required String to}) {
    // No-op for fake service
  }

  @override
  void editMessage({required String id, required String text}) {
    // No-op for fake service
  }

  @override
  void deleteMessage({required String id}) {
    // No-op for fake service
  }

  @override
  void reactToMessage(
      {required String messageId,
      required String reaction,
      required String from}) {
    // No-op for fake service
  }

  @override
  void emitMomentExtended(String momentId, String toUserId) {
    // No-op for fake service
  }

  @override
  void emitNoteLiked(String noteId, String toUserId) {
    // No-op for fake service
  }

  @override
  void emitStoryViewed(String storyId) {
    // No-op for fake service
  }

  @override
  void emitStoryLiked(String storyId) {
    // No-op for fake service
  }

  @override
  void emitMatchLiked(String user2Id) {
    // No-op for fake service
  }

  @override
  void emitMutualMatch(String user2Id) {
    // No-op for fake service
  }

  void dispose() {
    _messageController.close();
    _historyController.close();
    _typingController.close();
    _messageEditedController.close();
    _messageDeletedController.close();
    _onlineStatusController.close();
    _readController.close();
    _messageReactedController.close();
    _momentNotificationController.close();
    _noteNotificationController.close();
    _storyNotificationController.close();
    _matchNotificationController.close();
  }
}
