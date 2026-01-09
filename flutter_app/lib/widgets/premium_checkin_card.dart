import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/meengle_checkin.dart';
import '../services/checkin_service.dart';

/// Premium enhanced check-in card with advanced features
class PremiumCheckInCard extends StatefulWidget {
  final MeengleCheckIn checkIn;
  final VoidCallback? onTap;
  final VoidCallback? onCheckOut;
  final VoidCallback? onMessage;
  final VoidCallback? onAddFavourite;
  final bool isFavourited;
  final double? userDistance;

  const PremiumCheckInCard({
    super.key,
    required this.checkIn,
    this.onTap,
    this.onCheckOut,
    this.onMessage,
    this.onAddFavourite,
    this.isFavourited = false,
    this.userDistance,
  });

  @override
  State<PremiumCheckInCard> createState() => _PremiumCheckInCardState();
}

class _PremiumCheckInCardState extends State<PremiumCheckInCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Timer _expirationTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _initializeExpiration();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _initializeExpiration() {
    if (widget.checkIn.expiresAt != null) {
      _secondsRemaining =
          widget.checkIn.expiresAt!.difference(DateTime.now()).inSeconds;
    }

    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _expirationTimer.cancel();
    super.dispose();
  }

  String _formatTimeRemaining() {
    if (_secondsRemaining <= 0) return 'Expired';
    final hours = _secondsRemaining ~/ 3600;
    final minutes = (_secondsRemaining % 3600) ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getExpirationColor() {
    final percentage = (_secondsRemaining / (24 * 3600)) * 100;
    if (percentage < 10) return Colors.red;
    if (percentage < 25) return Colors.orange;
    return Colors.amber.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final vibeColor = MeengleCheckIn.getVibeColor(widget.checkIn.vibe);
    final vibeEmoji = MeengleCheckIn.getVibeEmoji(widget.checkIn.vibe);
    final colorValue = int.parse(vibeColor.replaceFirst('#', '0xFF'));

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(colorValue),
                  Color(colorValue).withAlpha((0.7 * 255).toInt()),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(colorValue).withAlpha((0.3 * 255).toInt()),
                  blurRadius: 16 + (_glowController.value * 4),
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withAlpha((0.2 * 255).toInt()),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: CustomPaint(
                      painter: VibePatternPainter(),
                    ),
                  ),
                ),

                // Glow effect
                if (widget.isFlashEvent)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withAlpha((0.2 * 255).toInt()),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Location & Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        widget.checkIn.locationName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTimeRemaining(),
                                      style: TextStyle(
                                        color: _getExpirationColor(),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (widget.userDistance != null) ...[
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.near_me,
                                        color: Colors.white70,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.userDistance!.toStringAsFixed(1)}m away',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Vibe Emoji & Favourite Button
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.15 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  vibeEmoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (widget.onAddFavourite != null)
                                GestureDetector(
                                  onTap: widget.onAddFavourite,
                                  child: Icon(
                                    widget.isFavourited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Vibe Tag with Flash Event Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.2 * 255).toInt()),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.checkIn.vibe.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (widget.isFlashEvent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withAlpha((0.3 * 255).toInt()),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.yellow.withAlpha((0.6 * 255).toInt()),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '?',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'FLASH EVENT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 12),

                      // User Info
                      if (widget.checkIn.username != null)
                        Row(
                          children: [
                            if (widget.checkIn.photoUrl != null)
                              ClipOval(
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  color: Colors.white.withAlpha((0.2 * 255).toInt()),
                                  child: Image.network(
                                    widget.checkIn.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(vibeEmoji),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withAlpha((0.2 * 255).toInt()),
                                ),
                                child: Center(child: Text(vibeEmoji)),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.checkIn.username ?? 'User',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.checkIn.age != null)
                                    Text(
                                      '${widget.checkIn.age} years old',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Badge or verification
                            if (widget.checkIn.isVerified ?? false)
                              const Tooltip(
                                message: 'Verified user',
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.lightBlue,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.checkIn.nearbyUserCount > 0)
                            Expanded(
                              child: _buildStatChip(
                                icon: Icons.people,
                                label:
                                    '${widget.checkIn.nearbyUserCount} nearby',
                              ),
                            ),
                          if (widget.checkIn.nearbyUserCount > 0)
                            const SizedBox(width: 8),
                          if (widget.checkIn.compatibilityScore != null)
                            Expanded(
                              child: _buildStatChip(
                                icon: Icons.favorite,
                                label:
                                    '${widget.checkIn.compatibilityScore!.toInt()}% match',
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Action Buttons
                      Row(
                        children: [
                          // Message Button
                          if (widget.onMessage != null)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.15 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: widget.onMessage,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Icon(
                                        Icons.message,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (widget.onMessage != null) const SizedBox(width: 8),

                          // View People Button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: widget.onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(colorValue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                'View People',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Close Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.15 * 255).toInt()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onCheckOut,
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class VibePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(center, (i + 1) * 15.0, paint);
    }
  }

  @override
  bool shouldRepaint(VibePatternPainter oldDelegate) => false;
}
