import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/emergency_contact.dart';

/// Widget to display location message in chat
class LocationMessageBubble extends StatelessWidget {
  final String senderName;
  final double latitude;
  final double longitude;
  final String? address;
  final double accuracy;
  final DateTime timestamp;
  final bool isEmergency;
  final String serviceType;
  final bool isFromMe;

  const LocationMessageBubble({
    required this.senderName,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.accuracy,
    required this.timestamp,
    required this.isEmergency,
    required this.serviceType,
    required this.isFromMe,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEmergency
              ? Colors.red.shade900
              : (isFromMe ? Colors.amber.shade700 : Colors.grey.shade800),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmergency
                ? Colors.red.shade700
                : Colors.amber.shade700.withAlpha(102),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isEmergency ? Colors.red : Colors.amber)
                  .withAlpha(51),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with emoji
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getEmoji(),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEmergency ? 'EMERGENCY LOCATION' : 'Location Shared',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Address
            if (address != null && address!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Coordinates
            Row(
              children: [
                const Icon(Icons.language, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$latitude, $longitude',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Accuracy
            Row(
              children: [
                const Icon(Icons.straighten, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  'Accuracy: ±${accuracy.toInt()}m',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Service type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                serviceType.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Open Map Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMap(latitude, longitude),
                icon: const Icon(Icons.map, size: 16),
                label: const Text('Open in Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Time
            Text(
              _formatTime(timestamp),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get emoji based on service type
  String _getEmoji() {
    switch (serviceType.toLowerCase()) {
      case 'favourite':
        return '??';
      case 'police':
        return '??';
      case 'hospital':
        return '??';
      case 'emergency':
        return '??';
      default:
        return '??';
    }
  }

  /// Open location in Google Maps
  Future<void> _openMap(double lat, double lng) async {
    final url = 'https://maps.google.com/?q=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  /// Format timestamp
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${time.month}/${time.day}/${time.year}';
    }
  }
}

/// Widget for emergency badge in messages list
class EmergencyMessageBadge extends StatelessWidget {
  final bool isEmergency;
  final String priority;

  const EmergencyMessageBadge({
    required this.isEmergency,
    required this.priority,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isEmergency) {
      return const SizedBox.shrink();
    }

    Color badgeColor;
    String badgeLabel;

    switch (priority) {
      case 'critical':
        badgeColor = Colors.red;
        badgeLabel = '?? CRITICAL';
        break;
      case 'high':
        badgeColor = Colors.red.shade700;
        badgeLabel = '?? HIGH';
        break;
      default:
        badgeColor = Colors.orange;
        badgeLabel = '? ALERT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        badgeLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
