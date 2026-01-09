import 'package:flutter/material.dart';
import '../services/api.dart';
import 'nearby_locations_screen.dart';
import 'locations_map_screen.dart';
import 'boost_screen.dart';
import 'premium_screen.dart';
import 'package:meengle_flutter/screens/swipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ApiService.getProfile();
      setState(() => _profile = profile);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : _error != null
                ? Text('Error: $_error')
                : _profile == null
                    ? Text('No profile')
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((_profile!['images'] ?? []).isNotEmpty) ...[
                              Center(
                                child: Image.network(
                                  ApiService.resolveAssetUrl(
                                      _profile!['images'][0]),
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.person, size: 80),
                                ),
                              ),
                              SizedBox(height: 12),
                            ],
                            Text('Name: ${_profile!['name'] ?? 'Unknown'}',
                                style: TextStyle(fontSize: 20)),
                            SizedBox(height: 8),
                            Text('Age: ${_profile!['age'] ?? '-'}'),
                            SizedBox(height: 8),
                            Text('Bio: ${_profile!['bio'] ?? ''}'),
                            SizedBox(height: 8),
                            if (_profile!['checkIn'] != null)
                              Text(
                                  'Checked in at: ${_profile!['checkIn']['locationName']}'),
                            SizedBox(height: 8),
                            Text(
                                'Check-in Streak: ${_profile!['checkInStreak'] ?? 0}'),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _loadProfile,
                                  child: Text('Refresh'),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);
                                    await ApiService.logout();
                                    if (mounted) {
                                      navigator.pushReplacementNamed('/');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey),
                                  child: Text('Logout'),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    final res = await Navigator.of(context)
                                        .pushNamed('/profile/edit');
                                    if (res == true) _loadProfile();
                                  },
                                  child: Text('Edit Profile'),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed('/matches'),
                                  child: Text('Matches'),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed('/payments'),
                                  child: Text('Payments'),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NearbyLocationsScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Check In'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LocationsMapScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Map'),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BoostScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Boost Profile'),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PremiumScreen(
                                            email: _profile?['email'] ?? ''),
                                      ),
                                    );
                                  },
                                  child: const Text('Premium'),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SwipeScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Swipe'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
