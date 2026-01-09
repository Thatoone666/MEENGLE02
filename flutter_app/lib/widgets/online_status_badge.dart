// Flutter: Online Status Widget
// File: flutter_app/lib/widgets/online_status_badge.dart

import 'package:flutter/material.dart';
import '../services/online_status_service.dart';

/// Widget to display online/offline status badge
class OnlineStatusBadge extends StatelessWidget {
  final String userId;
  final OnlineStatusService statusService;
  final Size? size;
  final bool showText;

  const OnlineStatusBadge({
    Key? key,
    required this.userId,
    required this.statusService,
    this.size = const Size(16, 16),
    this.showText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: statusService,
      builder: (context, _) {
        final isOnline = statusService.isUserOnline(userId);
        final isIdle = statusService.isUserIdle(userId);
        final statusText = statusService.getStatusText(userId);
        final statusColor = statusService.getStatusColor(userId);

        if (showText) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size!.width,
                height: size!.height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        return Container(
          width: size!.width,
          height: size!.height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: isOnline
              ? [
                  BoxShadow(
                    color: statusColor.withAlpha(100),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ]
              : [],
          ),
        );
      },
    );
  }
}

/// Widget to show full status card
class OnlineStatusCard extends StatelessWidget {
  final String userId;
  final String userName;
  final String? userImage;
  final OnlineStatusService statusService;
  final VoidCallback? onTap;

  const OnlineStatusCard({
    Key? key,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.statusService,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: statusService,
      builder: (context, _) {
        final isOnline = statusService.isUserOnline(userId);
        final isTyping = statusService.isUserTyping(userId);
        final statusText = statusService.getStatusText(userId);
        final statusColor = statusService.getStatusColor(userId);
        final statusIcon = statusService.getStatusIcon(userId);

        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: userImage != null
                  ? NetworkImage(userImage!)
                  : null,
                child: userImage == null
                  ? Icon(Icons.person, size: 24)
                  : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              if (isTyping)
                Text(
                  'Typing...',
                  style: TextStyle(
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Text(
                  '$statusIcon $statusText',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          onTap: onTap,
        );
      },
    );
  }
}

/// Widget to show online users count
class OnlineCountWidget extends StatelessWidget {
  final OnlineStatusService statusService;
  final TextStyle? style;

  const OnlineCountWidget({
    Key? key,
    required this.statusService,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: statusService,
      builder: (context, _) {
        // In a real app, you'd fetch this from server
        // For now, just show the icon
        return Tooltip(
          message: 'View online users',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: Color(0xFF4CAF50),
              ),
              SizedBox(width: 4),
              Text(
                'Online',
                style: style ?? TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
