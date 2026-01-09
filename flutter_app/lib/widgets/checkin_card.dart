import 'package:flutter/material.dart';
import 'package:meengle_flutter/models/meengle_checkin.dart';

/// Beautiful CheckIn card widget displaying user's check-in with vibe
class CheckInCard extends StatelessWidget {
  final MeengleCheckIn checkIn;
  final VoidCallback? onTap;
  final VoidCallback? onCheckOut;

  const CheckInCard({
    super.key,
    required this.checkIn,
    this.onTap,
    this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final vibeColor = MeengleCheckIn.getVibeColor(checkIn.vibe);
    final vibeEmoji = MeengleCheckIn.getVibeEmoji(checkIn.vibe);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(int.parse(vibeColor.replaceFirst('#', '0xFF'))),
              Color(int.parse(vibeColor.replaceFirst('#', '0xFF')))
                  .withValues(alpha: 0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(int.parse(vibeColor.replaceFirst('#', '0xFF')))
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: VibePatternPainter(),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Location & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    checkIn.locationName,
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
                            Text(
                              checkIn.timeRemaining,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Vibe Emoji
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          vibeEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Vibe tag
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      checkIn.vibe.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nearby users
                  if (checkIn.nearbyUserCount > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${checkIn.nearbyUserCount} people nearby',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  if (checkIn.isFlashEvent) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white30,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '⚡ ',
                            style: TextStyle(fontSize: 14),
                          ),
                          Expanded(
                            child: Text(
                              '${checkIn.flashEventName} - ${checkIn.flashEventExpiresAt?.difference(DateTime.now()).inMinutes ?? 0}m left',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:
                                Color(int.parse(vibeColor.replaceFirst('#', '0xFF'))),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'View People',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onCheckOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        child: const Icon(Icons.close, size: 18),
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
  }
}

/// Vibe selector widget for choosing check-in mood
class VibeSelector extends StatefulWidget {
  final Function(String vibe) onVibeSelected;

  const VibeSelector({
    super.key,
    required this.onVibeSelected,
  });

  @override
  State<VibeSelector> createState() => _VibeSelectorState();
}

class _VibeSelectorState extends State<VibeSelector> {
  String? _selectedVibe;

  @override
  Widget build(BuildContext context) {
    final vibes = [
      'party',
      'chill',
      'adventurous',
      'romantic',
      'casual',
      'energetic',
      'intellectual',
      'foodie',
      'sporty',
      'artsy',
      'nature',
      'nightlife',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'What\'s your vibe?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vibes.map((vibe) {
              final isSelected = _selectedVibe == vibe;
              final vibeColor = MeengleCheckIn.getVibeColor(vibe);
              final vibeEmoji = MeengleCheckIn.getVibeEmoji(vibe);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVibe = vibe;
                  });
                  widget.onVibeSelected(vibe);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(int.parse(vibeColor.replaceFirst('#', '0xFF')))
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vibeEmoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        vibe,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Streak badge widget
class StreakBadge extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final List<CheckInBadgeType> badges;

  const StreakBadge({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🔥 ', style: TextStyle(fontSize: 24)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$currentStreak Days',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Current Streak',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$longestStreak',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Best',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Badges',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges.take(3).map((badge) {
                final icon = badge.title.split(' ')[0];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// User avatar grid for nearby people
class UserAvatarGrid extends StatelessWidget {
  final List<MeengleCheckIn> users;
  final VoidCallback? onUserTap;

  const UserAvatarGrid({
    super.key,
    required this.users,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 16),
          ...users.take(8).map((user) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: onUserTap,
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(int.parse(MeengleCheckIn.getVibeColor(user.vibe)
                                .replaceFirst('#', '0xFF'))),
                            Color(int.parse(MeengleCheckIn.getVibeColor(user.vibe)
                                .replaceFirst('#', '0xFF')))
                                .withValues(alpha: 0.6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: user.photoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user.photoUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                MeengleCheckIn.getVibeEmoji(user.vibe),
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.username ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
          if (users.length > 8)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2A2A2A),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '+${users.length - 8}',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'More',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

/// Custom painter for vibe pattern background
class VibePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw circular pattern
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5),
        (i + 1) * 20.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(VibePatternPainter oldDelegate) => false;
}

