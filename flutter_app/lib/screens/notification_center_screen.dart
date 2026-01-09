import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final String type; // 'match', 'message', 'like', 'verification', 'promo'
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });
}

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  late List<Notification> _notifications;
  String _filterType = 'all'; // all, match, message, like, verification, promo

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // In a real app, fetch from backend
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _notifications = _getMockNotifications();
    });
  }

  List<Notification> _getMockNotifications() {
    return [
      Notification(
        id: '1',
        title: 'New Match!',
        message: 'Sarah just swiped right on you',
        type: 'match',
        imageUrl: 'https://via.placeholder.com/100',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        data: {'userId': 'user123'},
      ),
      Notification(
        id: '2',
        title: 'New Message',
        message: 'Hey! How are you doing?',
        type: 'message',
        imageUrl: 'https://via.placeholder.com/100',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
        data: {'userId': 'user456', 'matchId': 'match123'},
      ),
      Notification(
        id: '3',
        title: 'Someone Liked You',
        message: 'Emma liked your profile',
        type: 'like',
        imageUrl: 'https://via.placeholder.com/100',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
        data: {'userId': 'user789'},
      ),
      Notification(
        id: '4',
        title: 'Profile Verified',
        message: 'Your profile has been verified',
        type: 'verification',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      Notification(
        id: '5',
        title: 'Special Offer!',
        message: '50% off Premium - Limited time only!',
        type: 'promo',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
        data: {'promoId': 'promo123'},
      ),
      Notification(
        id: '6',
        title: 'New Match!',
        message: 'Jessica just swiped right on you',
        type: 'match',
        imageUrl: 'https://via.placeholder.com/100',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      Notification(
        id: '7',
        title: 'New Message',
        message: 'Thanks for the conversation!',
        type: 'message',
        imageUrl: 'https://via.placeholder.com/100',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  List<Notification> _getFilteredNotifications() {
    if (_filterType == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n.type == _filterType).toList();
  }

  Future<void> _markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      setState(() {
        _notifications[index] = Notification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          imageUrl: _notifications[index].imageUrl,
          timestamp: _notifications[index].timestamp,
          isRead: true,
          data: _notifications[index].data,
        );
      });
    }
  }

  Future<void> _deleteNotification(String id) async {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _notifications = _notifications.map((n) {
        return Notification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          imageUrl: n.imageUrl,
          timestamp: n.timestamp,
          isRead: true,
          data: n.data,
        );
      }).toList();
    });
  }

  Future<void> _clearAll() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _notifications.clear());
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(Notification notification) {
    _markAsRead(notification.id);

    switch (notification.type) {
      case 'match':
        Navigator.pushNamed(context, '/match', arguments: notification.data?['userId']);
        break;
      case 'message':
        Navigator.pushNamed(context, '/chat', arguments: notification.data?['matchId']);
        break;
      case 'like':
        Navigator.pushNamed(context, '/match', arguments: notification.data?['userId']);
        break;
      case 'verification':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'promo':
        Navigator.pushNamed(context, '/payments');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: _markAllAsRead,
                  child: const Row(
                    children: [
                      Icon(Icons.done_all, size: 18),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: _clearAll,
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_notifications.isNotEmpty) _buildFilterChips(),

          // Notifications list
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('all', 'All'),
          const SizedBox(width: 8),
          _buildFilterChip('match', '?? Match'),
          const SizedBox(width: 8),
          _buildFilterChip('message', '?? Message'),
          const SizedBox(width: 8),
          _buildFilterChip('like', '?? Like'),
          const SizedBox(width: 8),
          _buildFilterChip('verification', '? Verified'),
          const SizedBox(width: 8),
          _buildFilterChip('promo', '?? Promo'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    bool isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterType = value);
      },
      backgroundColor: Colors.transparent,
      selectedColor: Colors.blueAccent.withAlpha(102),
      side: BorderSide(
        color: isSelected ? Colors.blueAccent : Colors.grey.withAlpha(77),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.blueAccent : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildNotificationsList() {
    final filtered = _getFilteredNotifications();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No $_filterType notifications',
          style: TextStyle(color: Colors.grey.withAlpha(128)),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final notification = filtered[index];
        return _buildNotificationTile(notification);
      },
    );
  }

  Widget _buildNotificationTile(Notification notification) {
    return Dismissible(
      key: Key(notification.id),
      onDismissed: (_) => _deleteNotification(notification.id),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : Colors.blueAccent.withAlpha(26),
            border: Border(
              left: BorderSide(
                color: notification.isRead ? Colors.transparent : Colors.blueAccent,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              if (notification.imageUrl != null)
                Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getNotificationColor(notification.type),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      notification.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _getNotificationColor(notification.type).withAlpha(77),
                          child: Icon(
                            _getNotificationIcon(notification.type),
                            color: _getNotificationColor(notification.type),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getNotificationColor(notification.type).withAlpha(77),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                  ),
                ),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.withAlpha(179),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notification.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),

              // Action button
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => _markAsRead(notification.id),
                    enabled: !notification.isRead,
                    child: const Row(
                      children: [
                        Icon(Icons.done, size: 18),
                        SizedBox(width: 8),
                        Text('Mark as read'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () => _deleteNotification(notification.id),
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 18),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.withAlpha(179),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get likes, matches, and messages,\nthey\'ll show up here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'match':
        return Colors.pinkAccent;
      case 'message':
        return Colors.blueAccent;
      case 'like':
        return Colors.redAccent;
      case 'verification':
        return Colors.greenAccent;
      case 'promo':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'match':
        return Icons.favorite;
      case 'message':
        return Icons.chat;
      case 'like':
        return Icons.favorite_border;
      case 'verification':
        return Icons.verified_user;
      case 'promo':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
