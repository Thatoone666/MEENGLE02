import 'dart:async';
import 'dart:math';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? socket;
  String? _currentUserId;
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
  
  // Feature event controllers
  final _momentNotificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _noteNotificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _storyNotificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _matchNotificationController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<List<dynamic>> get history => _historyController.stream;
  Stream<String> get typing => _typingController.stream;
  Stream<Map<String, dynamic>> get messageEdited =>
      _messageEditedController.stream;
  Stream<String> get messageDeleted => _messageDeletedController.stream;
  Stream<Map<String, dynamic>> get onlineStatus =>
      _onlineStatusController.stream;
  Stream<Map<String, dynamic>> get read => _readController.stream;
  Stream<Map<String, dynamic>> get messageReacted =>
      _messageReactedController.stream;
  
  // Feature event streams
  Stream<Map<String, dynamic>> get momentNotifications => _momentNotificationController.stream;
  Stream<Map<String, dynamic>> get noteNotifications => _noteNotificationController.stream;
  Stream<Map<String, dynamic>> get storyNotifications => _storyNotificationController.stream;
  Stream<Map<String, dynamic>> get matchNotifications => _matchNotificationController.stream;

  void connect({required String userId, required String matchId}) {
    if (socket != null && socket!.connected) return;
    _currentUserId = userId;
    final tokenFuture = ApiService.getToken();
    tokenFuture.then((token) {
      final opts = <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'query': {'token': token ?? ''}
      };
      socket = io.io(ApiService.baseUrl, opts);
      int attempts = 0;

      void attemptConnect() {
        attempts += 1;
        socket!.connect();
      }

      socket!.on('connect', (_) {
        attempts = 0;

        socket!.emit('userOnline', userId);
        socket!.emit('join', {'userId': userId, 'matchId': matchId});
      });

      socket!.on('disconnect', (_) async {
        // try reconnect with exponential backoff
        final wait = min(30000, pow(2, attempts) * 1000).toInt();
        await Future.delayed(Duration(milliseconds: wait));
        attemptConnect();
      });

      socket!.on('history', (data) {
        if (data is List) _historyController.add(List<dynamic>.from(data));
      });

      socket!.on('message', (data) {
        if (data is Map) {
          _messageController.add(Map<String, dynamic>.from(data));
        }
      });

      socket!.on('messageEdited', (data) {
        if (data is Map) {
          _messageEditedController.add(Map<String, dynamic>.from(data));
        }
      });

      socket!.on('messageDeleted', (data) {
        if (data is Map && data.containsKey('id')) {
          _messageDeletedController.add(data['id'].toString());
        }
      });

      socket!.on('typing', (data) {
        if (data is Map && data.containsKey('from')) {
          final from = data['from']?.toString();
          if (from != null) _typingController.add(from);
        }
      });

      socket!.on('onlineStatus', (data) {
        if (data is Map) {
          _onlineStatusController.add(Map<String, dynamic>.from(data));
        }
      });

      socket!.on('read', (data) {
        if (data is Map) _readController.add(Map<String, dynamic>.from(data));
      });

      socket!.on('messageReacted', (data) {
        if (data is Map) {
          _messageReactedController.add(Map<String, dynamic>.from(data));
        }
      });

      // Feature event listeners
      socket!.on('moment:notification', (data) {
        if (data is Map) {
          _momentNotificationController.add(Map<String, dynamic>.from(data));
        }
      });

      socket!.on('note:notification', (data) {
        if (data is Map) {
          _noteNotificationController.add(Map<String, dynamic>.from(data));
        }
      });

      socket!.on('story:notification', (data) {
        if (data is Map) {
          _storyNotificationController.add(Map<String, dynamic>.from(data));
        }
      });

      socket!.on('match:notification', (data) {
        if (data is Map) {
          _matchNotificationController.add(Map<String, dynamic>.from(data));
        }
      });

      attemptConnect();
    });
  }

  void sendMessage(
      {required String from,
      required String to,
      required String text,
      String? replyTo}) {
    socket?.emit(
        'message', {'from': from, 'to': to, 'text': text, 'replyTo': replyTo});
  }

  void sendTyping({required String from, required String to}) {
    if (socket == null) return;
    socket!.emit('typing', {'from': from, 'to': to});
  }

  void sendRead({required String from, required String to}) {
    if (socket == null) return;
    socket!.emit('read', {
      'from': from,
      'to': to,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  void editMessage({required String id, required String text}) {
    if (socket == null) return;
    socket!.emit('editMessage', {'id': id, 'text': text});
  }

  void deleteMessage({required String id}) {
    if (socket == null) return;
    socket!.emit('deleteMessage', {'id': id});
  }

  void reactToMessage(
      {required String messageId,
      required String reaction,
      required String from}) {
    if (socket == null) return;
    socket!.emit('reactToMessage',
        {'messageId': messageId, 'reaction': reaction, 'from': from});
  }

  // Feature event emissions
  void emitMomentExtended(String momentId, String toUserId) {
    if (socket == null || _currentUserId == null) return;
    socket!.emit('moment:extended', {
      'momentId': momentId,
      'fromUserId': _currentUserId,
      'toUserId': toUserId,
    });
  }

  void emitNoteLiked(String noteId, String toUserId) {
    if (socket == null || _currentUserId == null) return;
    socket!.emit('note:liked', {
      'noteId': noteId,
      'fromUserId': _currentUserId,
      'toUserId': toUserId,
    });
  }

  void emitStoryViewed(String storyId) {
    if (socket == null || _currentUserId == null) return;
    socket!.emit('story:viewed', {
      'storyId': storyId,
      'viewedByUserId': _currentUserId,
    });
  }

  void emitStoryLiked(String storyId) {
    if (socket == null || _currentUserId == null) return;
    socket!.emit('story:liked', {
      'storyId': storyId,
      'likedByUserId': _currentUserId,
    });
  }

  void emitMatchLiked(String user2Id) {
    if (socket == null || _currentUserId == null) return;
    socket!.emit('match:liked', {
      'user1Id': _currentUserId,
      'user2Id': user2Id,
    });
  }

  void emitMutualMatch(String user2Id) {
    if (socket == null || _currentUserId == null) return;
    socket!.emit('match:mutual', {
      'user1Id': _currentUserId,
      'user2Id': user2Id,
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }
}
