import 'package:flutter/material.dart';
import '../../../models/meengle_roam.dart';
import '../../animations/premium_animations.dart';

class RoamGuideCard extends StatefulWidget {
  final LocalGuide guide;
  final VoidCallback onTap;

  const RoamGuideCard({
    required this.guide,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<RoamGuideCard> createState() => _RoamGuideCardState();
}

class _RoamGuideCardState extends State<RoamGuideCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: PremiumAnimations.medioDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.97).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.amber.shade700, width: 1.5),
          ),
          color: const Color(0xFF1A1A1A),
          elevation: 12,
          shadowColor: Colors.amber.shade700,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: PremiumAnimations.premiumGlow(
                color: Colors.amber.shade700,
                intensity: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guide Header with Avatar
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.amber.shade700,
                          boxShadow: PremiumAnimations.premiumGlow(
                            color: Colors.amber.shade700,
                            intensity: 0.4,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.guide.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.guide.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                if (widget.guide.isVerified)
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: PremiumAnimations
                                          .premiumGlow(
                                        color: Colors.cyan.shade400,
                                        intensity: 0.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.verified,
                                      color: Colors.cyan.shade400,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow.shade600,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.guide.rating}/5 (${widget.guide.reviewCount})',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bio
                  Text(
                    widget.guide.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Specialties Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (var specialty in widget.guide.specialties.take(3))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade900,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.amber.shade700.withAlpha(51),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            specialty,
                            style: TextStyle(
                              color: Colors.amber.shade400,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (widget.guide.specialties.length > 3)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${widget.guide.specialties.length - 3}',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Years Local Badge
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        color: Colors.amber.shade400,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.guide.yearsLocal} years local',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700.withAlpha(51),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.amber.shade700.withAlpha(77),
                          ),
                        ),
                        child: Text(
                          'Contact Guide',
                          style: TextStyle(
                            color: Colors.amber.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
