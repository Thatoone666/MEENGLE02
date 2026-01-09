// Flutter: Online Status Service
// File: flutter_app/lib/services/online_status_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'dart:async';

class OnlineStatusService with ChangeNotifier {
  late IO.Socket _socket;
  final Map<String, Map<String, dynamic>> _userStatuses = {};
  final Map<String, DateTime> _typingUsers = {};
  Timer? _activityTimer;
  String? _currentUserId;

  OnlineStatusService({required String apiUrl}) {
    _initializeSocket(apiUrl);
  }

  void _initializeSocket(String apiUrl) {
    _socket = IO.io(
      apiUrl,
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
    );

    _socket.on('connect', (_) {
      print('[ONLINE] Connected to server');
      _notifyOnline();
      _startActivityTracking();
    });

    _socket.on('user-status-changed', (data) {
      final userId = data['userId'];
      final status = data['status'];
      
      _userStatuses[userId] = {
        'status': status,
        'timestamp': DateTime.parse(data['timestamp'] ?? DateTime.now().toString())
      };
      
      notifyListeners();
    });

    _socket.on('user-typing', (data) {
      final userId = data['userId'];
      _typingUsers[userId] = DateTime.now().add(Duration(seconds: 3));
      notifyListeners();
    });

    _socket.on('user-stop-typing', (data) {
      final userId = data['userId'];
      _typingUsers.remove(userId);
      notifyListeners();
    });

    _socket.on('disconnect', (_) {
      print('[OFFLINE] Disconnected from server');
      _activityTimer?.cancel();
    });
  }

  /// Connect user to socket
  void connectUser(String userId) {
    _currentUserId = userId;
    
    if (!_socket.connected) {
      _socket.connect();
    }
    
    // Notify server user is online
    _socket.emit('user-online', {
      'userId': userId,
      'userData': {
        'connectedAt': DateTime.now().toIso8601String()
      }
    });
    
    // Join personal room for direct messages
    _socket.emit('join-room', {
      'userId': userId
    });
  }

  /// Notify user is online
  void _notifyOnline() {
    if (_currentUserId != null) {
      _socket.emit('user-online', {
        'userId': _currentUserId,
        'userData': {
          'connectedAt': DateTime.now().toIso8601String()
        }
      });
    }
  }

  /// Track user activity
  void _startActivityTracking() {
    _activityTimer?.cancel();
    
    _activityTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _socket.emit('user-activity', {
        'timestamp': DateTime.now().toIso8601String()
      });
    });
  }

  /// Notify user is typing
  void notifyTyping(String recipientId) {
    _socket.emit('user-typing', {
      'recipientId': recipientId,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  /// Notify user stopped typing
  void notifyStoppedTyping(String recipientId) {
    _socket.emit('user-stop-typing', {
      'recipientId': recipientId,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  /// Get status for single user
  Map<String, dynamic>? getUserStatus(String userId) {
    return _userStatuses[userId];
  }

  /// Check if user is online
  bool isUserOnline(String userId) {
    final status = _userStatuses[userId];
    return status != null && status['status'] == 'online';
  }

  /// Check if user is idle
  bool isUserIdle(String userId) {
    final status = _userStatuses[userId];
    return status != null && status['status'] == 'idle';
  }

  /// Request statuses for multiple users
  Future<Map<String, dynamic>> getStatusesForUsers(List<String> userIds) async {
    _socket.emit('request-statuses', {
      'userIds': userIds
    });
    
    // Wait for response
    await Future.delayed(Duration(milliseconds: 500));
    
    final result = <String, dynamic>{};
    for (var userId in userIds) {
      result[userId] = getUserStatus(userId) ?? {
        'isOnline': false,
        'status': 'offline'
      };
    }
    
    return result;
  }

  /// Get user status display text
  String getStatusText(String userId) {
    final status = getUserStatus(userId);
    
    if (status == null) {
      return 'Offline';
    }
    
    if (status['status'] == 'online') {
      return 'Online now';
    } else if (status['status'] == 'idle') {
      return 'Away';
    } else {
      return 'Offline';
    }
  }

  /// Get user status color
  Color getStatusColor(String userId) {
    if (isUserOnline(userId)) {
      return Color(0xFF4CAF50); // Green
    } else if (isUserIdle(userId)) {
      return Color(0xFFFFC107); // Amber
    } else {
      return Color(0xFF9E9E9E); // Grey
    }
  }

  /// Get user status icon
  String getStatusIcon(String userId) {
    if (isUserOnline(userId)) {
      return '??'; // Green circle
    } else if (isUserIdle(userId)) {
      return '??'; // Yellow circle
    } else {
      return '?'; // Black circle
    }
  }

  /// Check if user is typing
  bool isUserTyping(String userId) {
    final typingTime = _typingUsers[userId];
    if (typingTime == null) return false;
    
    // Remove if expired
    if (DateTime.now().isAfter(typingTime)) {
      _typingUsers.remove(userId);
      return false;
    }
    
    return true;
  }

  /// Disconnect user
  void disconnectUser() {
    _activityTimer?.cancel();
    _socket.disconnect();
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    _socket.dispose();
    super.dispose();
  }
}
