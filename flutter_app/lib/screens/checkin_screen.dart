import 'package:flutter/material.dart';
import 'package:meengle_flutter/services/checkin_service.dart';
import 'package:meengle_flutter/widgets/checkin_card.dart';
import 'package:meengle_flutter/models/meengle_checkin.dart';

class CheckInScreen extends StatefulWidget {
  final String locationName;
  final double? latitude;
  final double? longitude;

  const CheckInScreen({
    super.key, 
    required this.locationName,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _vibeController = TextEditingController();
  String _selectedVibe = '';
  bool _loading = false;
  String? _error;
  List<dynamic>? _checkIns;
  CheckInStreak? _streak;
  List<FlashEvent> _flashEvents = [];
  
  // User info for check-in
  late String _userId;
  late String _username;
  late String _photoUrl;
  late int _age;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _loadStreakAndEvents();
    _fetchCheckIns();
  }

  void _initializeUserData() {
    // TODO: In production, fetch from auth provider
    _userId = 'current-user-id';
    _username = 'Current User';
    _photoUrl = 'https://via.placeholder.com/150';
    _age = 25;
  }

  @override
  void dispose() {
    _vibeController.dispose();
    super.dispose();
  }

  Future<void> _loadStreakAndEvents() async {
    try {
      final streak = await CheckInService.getUserStreak(_userId);
      final events = await CheckInService.getActiveFlashEvents();
      
      if (mounted) {
        setState(() {
          _streak = streak;
          _flashEvents = events;
        });
      }
    } catch (e) {
      debugPrint('Error loading streak/events: $e');
    }
  }

  Future<void> _fetchCheckIns() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final checkIns = await CheckInService.getCheckIns(widget.locationName);
      if (mounted) {
        setState(() {
          _checkIns = checkIns;
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

      await _loadStreakAndEvents();
      await _fetchCheckIns();

      if (mounted) {
        _vibeController.clear();
        setState(() {
          _selectedVibe = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checked in successfully!')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in at ${widget.locationName}'),
        elevation: 0,
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCheckIns,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Streak badge
                if (_streak != null)
                  StreakBadge(
                    currentStreak: _streak!.currentStreak,
                    longestStreak: _streak!.longestStreak,
                    badges: _streak!.badges,
                  ),

                const SizedBox(height: 12),

                // Flash events banner
                if (_flashEvents.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _flashEvents.length,
                      itemBuilder: (context, i) {
                        final event = _flashEvents[i];
                        return Container(
                          width: 260,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black87, Colors.black54],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
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
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${event.timeRemaining} left',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('Join'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // Vibe selector
                VibeSelector(
                  onVibeSelected: (v) {
                    setState(() {
                      _selectedVibe = v;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Check-in form
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _vibeController,
                        decoration: InputDecoration(
                          hintText: 'Add a note (optional)',
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: const TextStyle(color: Colors.white54),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loading ? null : _checkIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Check In'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Error message
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),

                const SizedBox(height: 16),

                // Nearby people header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nearby People',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _fetchCheckIns,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // People list
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_checkIns == null || _checkIns!.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No one is checked in here yet.\nBe the first!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: _checkIns!.length,
                      itemBuilder: (context, index) {
                        final raw = _checkIns![index] as Map<String, dynamic>;
                        try {
                          final checkIn = MeengleCheckIn.fromJson({
                            'id': raw['_id'] ?? raw['id'] ?? '$index',
                            'userId': raw['user']?['_id'] ?? 'unknown',
                            'locationName': widget.locationName,
                            'latitude': (raw['latitude'] as num?)?.toDouble() ?? 0.0,
                            'longitude': (raw['longitude'] as num?)?.toDouble() ?? 0.0,
                            'vibe': raw['vibe'] ?? 'casual',
                            'vibeEmojis': [MeengleCheckIn.getVibeEmoji(raw['vibe'] ?? 'casual')],
                            'createdAt': raw['createdAt'] ?? DateTime.now().toIso8601String(),
                            'expiresAt': raw['expiresAt'] ?? DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
                            'minutesRemaining': raw['minutesRemaining'] ?? 1440,
                            'nearbyUserCount': raw['nearbyUserCount'] ?? 0,
                            'isFlashEvent': raw['isFlashEvent'] ?? false,
                            'username': raw['user']?['name'] ?? 'User',
                            'photoUrl': raw['user']?['images']?[0],
                            'age': raw['user']?['age'],
                          });

                          return CheckInCard(
                            checkIn: checkIn,
                            onTap: () {},
                            onCheckOut: () async {
                              await CheckInService.checkOut();
                              await _fetchCheckIns();
                            },
                          );
                        } catch (e) {
                          debugPrint('Error parsing check-in: $e');
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
