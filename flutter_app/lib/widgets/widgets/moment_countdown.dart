import 'package:flutter/material.dart';
import 'dart:async';

/// Widget to display a countdown timer for expiring moments
class MomentCountdown extends StatefulWidget {
  final DateTime expiresAt;
  final VoidCallback? onExtend;
  final bool extensionsAvailable;
  final int extensionDurationMinutes;

  const MomentCountdown({
    super.key,
    required this.expiresAt,
    this.onExtend,
    this.extensionsAvailable = true,
    this.extensionDurationMinutes = 360, // 6 hours
  });

  @override
  State<MomentCountdown> createState() => _MomentCountdownState();
}

class _MomentCountdownState extends State<MomentCountdown> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    setState(() {
      _remainingTime = widget.expiresAt.difference(DateTime.now());
      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Color _getColor() {
    final totalSeconds = widget.expiresAt.difference(DateTime(2000)).inSeconds;
    final remainingSeconds = _remainingTime.inSeconds;
    final percentage = remainingSeconds / totalSeconds;

    if (percentage > 0.5) {
      return Colors.green.shade400;
    } else if (percentage > 0.25) {
      return Colors.amber.shade400;
    } else {
      return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _remainingTime <= Duration.zero;
    final color = _getColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
        color: color.withValues(alpha: 0.1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time Remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isExpired)
                    Text(
                      'EXPIRED',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    )
                  else
                    Text(
                      _formatTime(_remainingTime),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                ],
              ),
              if (!isExpired && widget.extensionsAvailable && widget.onExtend != null)
                ElevatedButton.icon(
                  onPressed: widget.onExtend,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Extend'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.black,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: isExpired
                  ? 0
                  : _remainingTime.inSeconds /
                      widget.expiresAt
                          .difference(DateTime.now().subtract(_remainingTime))
                          .inSeconds,
              minHeight: 6,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 12),
          // Warning message
          if (_remainingTime.inHours < 1 && !isExpired)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade900.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.shade400,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This match expires soon!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

