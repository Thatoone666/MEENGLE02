import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api.dart';
import 'chat_side_panel.dart';

class ChatInfoPanel extends StatelessWidget {
  final Map<String, dynamic>? match;
  final bool isOnline;
  final VoidCallback? onClose;

  const ChatInfoPanel({
    super.key,
    required this.match,
    required this.isOnline,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchName = match?['name'] ?? 'User';
    final avatarUrl = match?['images'] != null && match!['images'].isNotEmpty
        ? ApiService.resolveAssetUrl(match!['images'][0])
        : null;

    return ChatSidePanel(
      title: 'Profile Details',
      onClose: onClose,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Hero(
              tag: 'profile-${match?['id'] ?? match?['_id']}',
              child: CircleAvatar(
                radius: 60,
                backgroundImage: avatarUrl != null
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              matchName,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          Center(
            child: Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: isOnline
                    ? Colors.greenAccent[400]
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            theme,
            'About',
            match?['bio'] ?? 'No bio provided',
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            theme,
            'Location',
            match?['location'] ?? 'Not specified',
          ),
          if (match?['interests'] != null) ...[
            const SizedBox(height: 16),
            _buildInfoSection(
              theme,
              'Interests',
              (match!['interests'] as List).join(', '),
            ),
          ],
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _showReportDialog(context);
          },
          icon: const Icon(Icons.flag),
          label: const Text('Report'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.block),
          label: const Text('Block'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey.withValues(alpha: 0.8),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
          label: const Text('Unmatch'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.orange.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: const Text('Why are you reporting this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User reported successfully')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}