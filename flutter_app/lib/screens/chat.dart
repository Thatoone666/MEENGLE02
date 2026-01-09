import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final String matchName;
  final String? matchImage;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.matchName,
    this.matchImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket _socket;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _loadChatHistory();
  }

  void _initSocket() {
    _socket = IO.io('http://localhost:3001', <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.on('connect', (_) {
      print('Connected to chat');
      if (mounted) setState(() => _isConnecting = false);
      _socket.emit('join-chat', {
        'userId': APIService._userId,
        'matchId': widget.matchId,
      });
    });

    _socket.on('receive-message', (data) {
      if (mounted) {
        setState(() {
          _messages.add({
            'userId': data['userId'],
            'message': data['message'],
            'timestamp': data['timestamp'],
            'isOwn': data['userId'] == APIService._userId,
          });
        });
      }
    });

    _socket.on('user-typing', (data) {
      if (data['userId'] == widget.matchId && mounted) {
        setState(() => _isTyping = true);
      }
    });

    _socket.on('user-stop-typing', (data) {
      if (data['userId'] == widget.matchId && mounted) {
        setState(() => _isTyping = false);
      }
    });

    _socket.on('disconnect', (_) {
      print('Disconnected from chat');
      if (mounted) setState(() => _isConnecting = true);
    });

    _socket.on('error', (error) {
      print('Socket error: $error');
    });
  }

  Future<void> _loadChatHistory() async {
    try {
      final messages = await APIService.getChatHistory(widget.matchId);
      if (mounted) {
        setState(() {
          _messages.clear();
          for (var msg in messages) {
            _messages.add({
              'userId': msg['senderId'],
              'message': msg['message'],
              'timestamp': msg['timestamp'],
              'isOwn': msg['senderId'] == APIService._userId,
            });
          }
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    _socket.emit('send-message', {
      'userId': APIService._userId,
      'matchId': widget.matchId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      setState(() {
        _messages.add({
          'userId': APIService._userId,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          'isOwn': true,
        });
      });
    }

    _socket.emit('stop-typing', {
      'userId': APIService._userId,
      'matchId': widget.matchId,
    });
  }

  void _onTyping() {
    _socket.emit('typing', {
      'userId': APIService._userId,
      'matchId': widget.matchId,
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.matchName),
            if (_isTyping)
              const Text('Typing...', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
            else if (!_isConnecting)
              const Text('Online', style: TextStyle(fontSize: 12, color: Colors.green))
            else
              const Text('Connecting...', style: TextStyle(fontSize: 12, color: Colors.orange)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[_messages.length - 1 - index];
                      final isOwn = msg['isOwn'] as bool;
                      return Align(
                        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isOwn ? Colors.blue : Colors.grey[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg['message'] as String, style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (_) => _onTyping(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(mini: true, onPressed: _sendMessage, child: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
