import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/meengle_checkin.dart';
import '../services/checkin_service.dart';
import '../widgets/premium_checkin_card.dart';
import '../animations/premium_animations.dart';

/// Enhanced premium check-in screen with advanced features
class AdvancedCheckInScreen extends StatefulWidget {
  final String locationName;
  final double? latitude;
  final double? longitude;

  const AdvancedCheckInScreen({
    super.key,
    required this.locationName,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  @override
  State<AdvancedCheckInScreen> createState() => _AdvancedCheckInScreenState();
}

class _AdvancedCheckInScreenState extends State<AdvancedCheckInScreen>
    with WidgetsBindingObserver {
  final _noteController = TextEditingController();
  String _selectedVibe = '';
  bool _loading = false;
  bool _isCheckedIn = false;
  String? _error;
  List<MeengleCheckIn> _checkIns = [];
  List<MeengleCheckIn> _filteredCheckIns = [];
  CheckInStreak? _streak;
  List<FlashEvent> _flashEvents = [];
  Position? _userPosition;
  late Timer _refreshTimer;
  late Timer _locationUpdateTimer;

  // User data
  late String _userId;
  late String _username;
  late String _photoUrl;
  late int _age;

  // Filtering
  Set<String> _selectedVibes = {};
  bool _showOnlyNearby = false;
  double _nearbyRadius = 500; // meters
  bool _showFlashEventsOnly = false;
  List<MeengleCheckIn> _favouritedUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeUserData();
    _initializeScreen();
  }

  void _initializeUserData() {
    // TODO: In production, fetch from auth provider
    _userId = 'current-user-id';
    _username = 'Current User';
    _photoUrl = 'https://via.placeholder.com/150';
    _age = 25;
  }

  Future<void> _initializeScreen() async {
    await _getUserLocation();
    await _loadUserStreak();
    await _loadFlashEvents();
    await _fetchCheckIns();
    _setupAutoRefresh();
    _setupLocationUpdates();
  }

  Future<void> _getUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      _userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _setupLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _getUserLocation();
    });
  }

  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _fetchCheckIns();
      }
    });
  }

  Future<void> _loadUserStreak() async {
    try {
      final streak = await CheckInService.getUserStreak(_userId);
      if (mounted) {
        setState(() {
          _streak = streak;
        });
      }
    } catch (e) {
      debugPrint('Error loading streak: $e');
    }
  }

  Future<void> _loadFlashEvents() async {
    try {
      final events = await CheckInService.getActiveFlashEvents();
      if (mounted) {
        setState(() {
          _flashEvents = events;
        });
      }
    } catch (e) {
      debugPrint('Error loading flash events: $e');
    }
  }

  Future<void> _fetchCheckIns() async {
    try {
      final checkIns =
          await CheckInService.getCheckIns(widget.locationName);

      if (mounted) {
        setState(() {
          _checkIns = checkIns.map((json) {
            try {
              return MeengleCheckIn.fromJson({
                'id': json['_id'] ?? json['id'] ?? '',
                'userId': json['user']?['_id'] ?? 'unknown',
                'locationName': widget.locationName,
                'latitude':
                    (json['latitude'] as num?)?.toDouble() ?? widget.latitude ?? 0.0,
                'longitude':
                    (json['longitude'] as num?)?.toDouble() ?? widget.longitude ?? 0.0,
                'vibe': json['vibe'] ?? 'casual',
                'vibeEmojis': [MeengleCheckIn.getVibeEmoji(json['vibe'] ?? 'casual')],
                'createdAt': json['createdAt'] ?? DateTime.now().toIso8601String(),
                'expiresAt': json['expiresAt'] ??
                    DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
                'minutesRemaining': json['minutesRemaining'] ?? 1440,
                'nearbyUserCount': json['nearbyUserCount'] ?? 0,
                'isFlashEvent': json['isFlashEvent'] ?? false,
                'username': json['user']?['name'] ?? 'User',
                'photoUrl': json['user']?['images']?[0],
                'age': json['user']?['age'],
                'isVerified': json['user']?['isVerified'] ?? false,
                'compatibilityScore': json['compatibilityScore'],
              });
            } catch (e) {
              debugPrint('Error parsing check-in: $e');
              return null;
            }
          }).whereType<MeengleCheckIn>().toList();

          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading check-ins: $e';
        });
      }
    }
  }

  void _applyFilters() {
    _filteredCheckIns = _checkIns.where((checkIn) {
      // Vibe filter
      if (_selectedVibes.isNotEmpty && !_selectedVibes.contains(checkIn.vibe)) {
        return false;
      }

      // Flash event filter
      if (_showFlashEventsOnly && !checkIn.isFlashEvent) {
        return false;
      }

      // Nearby filter
      if (_showOnlyNearby && _userPosition != null) {
        final distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          checkIn.latitude,
          checkIn.longitude,
        );

        if (distance > _nearbyRadius) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort by distance
    if (_userPosition != null) {
      _filteredCheckIns.sort((a, b) {
        final distA = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          a.latitude,
          a.longitude,
        );

        final distB = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          b.latitude,
          b.longitude,
        );

        return distA.compareTo(distB);
      });
    }
  }

  Future<void> _checkIn() async {
    if (_selectedVibe.isEmpty) {
      setState(() {
        _error = 'Please select a vibe';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await CheckInService.checkIn(
        widget.locationName,
        _selectedVibe,
        latitude: widget.latitude ?? 0.0,
        longitude: widget.longitude ?? 0.0,
        username: _username,
        photoUrl: _photoUrl,
        age: _age,
      );

      await _loadUserStreak();
      await _fetchCheckIns();

      if (mounted) {
        _noteController.clear();
        setState(() {
          _selectedVibe = '';
          _isCheckedIn = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Checked in successfully! ??'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );

        // Auto-close after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _addFavourite(MeengleCheckIn checkIn) async {
    setState(() {
      if (_favouritedUsers.any((u) => u.userId == checkIn.userId)) {
        _favouritedUsers.removeWhere((u) => u.userId == checkIn.userId);
      } else {
        _favouritedUsers.add(checkIn);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favouritedUsers.any((u) => u.userId == checkIn.userId)
              ? 'Added to favourites!'
              : 'Removed from favourites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  double? _getUserDistance(MeengleCheckIn checkIn) {
    if (_userPosition == null) return null;

    return Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      checkIn.latitude,
      checkIn.longitude,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _refreshTimer.cancel();
    _locationUpdateTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchCheckIns();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check In',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.locationName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        actions: [
          if (_streak != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    const Text(
                      '??',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_streak!.currentStreak}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'days',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCheckIns,
        color: Colors.amber.shade700,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flash Events Carousel
                if (_flashEvents.isNotEmpty) ...[
                  const Text(
                    '? Flash Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _flashEvents.length,
                      itemBuilder: (context, index) {
                        final event = _flashEvents[index];
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade700,
                                Colors.amber.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withAlpha((0.3 * 255).toInt()),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(event.emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${event.timeRemaining} left',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha((0.8 * 255).toInt()),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.amber.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Join',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Vibe Selector
                const Text(
                  'Select Your Vibe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildVibeSelectorGrid(),

                const SizedBox(height: 16),

                // Note Input
                TextField(
                  controller: _noteController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Add a note (optional)',
                    hintStyle: TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),

                const SizedBox(height: 12),

                // Error Message
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withAlpha((0.5 * 255).toInt()),
                      ),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 12),

                // Check In Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading || _selectedVibe.isEmpty
                        ? null
                        : _checkIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _loading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.black.withAlpha((0.5 * 255).toInt()),
                              ),
                            ),
                          )
                        : const Text(
                            'Check In Now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Filters Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'People Checked In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedVibes.isNotEmpty ||
                        _showOnlyNearby ||
                        _showFlashEventsOnly)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVibes.clear();
                            _showOnlyNearby = false;
                            _showFlashEventsOnly = false;
                            _applyFilters();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Clear Filters',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Quick Filter Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip(
                      label: 'Nearby',
                      selected: _showOnlyNearby,
                      onTap: () {
                        setState(() {
                          _showOnlyNearby = !_showOnlyNearby;
                          _applyFilters();
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Flash Events',
                      selected: _showFlashEventsOnly,
                      onTap: () {
                        setState(() {
                          _showFlashEventsOnly = !_showFlashEventsOnly;
                          _applyFilters();
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Check Ins List
                if (_filteredCheckIns.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person_off,
                            color: Colors.white38,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No one checked in yet',
                            style: TextStyle(
                              color: Colors.white.withAlpha((0.5 * 255).toInt()),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: _filteredCheckIns.map((checkIn) {
                      return PremiumCheckInCard(
                        checkIn: checkIn,
                        isFavourited: _favouritedUsers
                            .any((u) => u.userId == checkIn.userId),
                        userDistance: _getUserDistance(checkIn),
                        onTap: () {},
                        onMessage: () {
                          // Open chat
                        },
                        onAddFavourite: () => _addFavourite(checkIn),
                        onCheckOut: () async {
                          await CheckInService.checkOut();
                          await _fetchCheckIns();
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVibeSelectorGrid() {
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

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: vibes.map((vibe) {
        final isSelected = _selectedVibe == vibe;
        final vibeColor = MeengleCheckIn.getVibeColor(vibe);
        final vibeEmoji = MeengleCheckIn.getVibeEmoji(vibe);
        final colorValue = int.parse(vibeColor.replaceFirst('#', '0xFF'));

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedVibe = isSelected ? '' : vibe;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(colorValue)
                  : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withAlpha((0.2 * 255).toInt()),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(colorValue).withAlpha((0.4 * 255).toInt()),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
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
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.amber.shade700
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.amber.shade700
                : Colors.white.withAlpha((0.2 * 255).toInt()),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
