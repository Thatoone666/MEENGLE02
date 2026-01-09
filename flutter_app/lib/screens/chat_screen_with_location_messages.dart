import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/location_message_bubble.dart';

/// Example chat screen with location message support
class ChatScreenWithLocationShares extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreenWithLocationShares({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreenWithLocationShares> createState() =>
      _ChatScreenWithLocationSharesState();
}

class _ChatScreenWithLocationSharesState
    extends State<ChatScreenWithLocationShares> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupRealTimeListener();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    // Load messages from backend
    // This is a mock implementation
    messages = [
      {
        'id': '1',
        'type': 'text',
        'content': 'Hey, how are you?',
        'fromUserId': 'user123',
        'fromUserName': 'Me',
        'isFromMe': true,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      },
      {
        'id': '2',
        'type': 'text',
        'content': 'I\'m doing great! How about you?',
        'fromUserId': 'user456',
        'fromUserName': widget.otherUserName,
        'isFromMe': false,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
      },
      {
        'id': '3',
        'type': 'location_share',
        'content': '?? EMERGENCY LOCATION SHARE\n\nI\'m sharing my location with you',
        'fromUserId': 'user456',
        'fromUserName': widget.otherUserName,
        'isFromMe': false,
        'isEmergency': false,
        'priority': 'normal',
        'serviceType': 'favourite',
        'locationData': {
          'latitude': 40.7128,
          'longitude': -74.0060,
          'accuracy': 12.5,
          'address': '123 Main St, New York, NY 10001, USA',
        },
        'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
      },
      {
        'id': '4',
        'type': 'location_share',
        'content': '?? EMERGENCY LOCATION SHARE\n\nSending emergency location',
        'fromUserId': 'user123',
        'fromUserName': 'Me',
        'isFromMe': true,
        'isEmergency': true,
        'priority': 'high',
        'serviceType': 'police',
        'locationData': {
          'latitude': 40.7580,
          'longitude': -73.9855,
          'accuracy': 8.3,
          'address': '456 Park Ave, New York, NY 10022, USA',
        },
        'timestamp': DateTime.now(),
      },
    ];
  }

  void _setupRealTimeListener() {
    // Setup WebSocket listener for new messages
    // In production, connect to your WebSocket server
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    // Send to backend
    // In production, call your message API
    print('Sending message: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName),
            const SizedBox(height: 4),
            Text(
              'Online',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade400,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                // Text message
                if (msg['type'] == 'text') {
                  return _buildTextMessage(msg);
                }

                // Location message
                if (msg['type'] == 'location_share') {
                  return LocationMessageBubble(
                    senderName: msg['fromUserName'],
                    latitude: msg['locationData']['latitude'],
                    longitude: msg['locationData']['longitude'],
                    address: msg['locationData']['address'],
                    accuracy: msg['locationData']['accuracy'],
                    timestamp: msg['timestamp'],
                    isEmergency: msg['isEmergency'] ?? false,
                    serviceType: msg['serviceType'],
                    isFromMe: msg['isFromMe'],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1A1A1A),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                  color: Colors.amber.shade700,
                ),

                // Message input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.amber.shade700,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> message) {
    final isFromMe = message['isFromMe'];

    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isFromMe ? Colors.amber.shade700 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message['content'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
