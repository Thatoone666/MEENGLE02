import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meengle_flutter/models/meengle_checkin.dart';
import 'package:meengle_flutter/services/checkin_service.dart';
import 'package:meengle_flutter/screens/checkin_screen.dart';
import 'dart:async';

/// Heat map based location discovery screen
/// Shows where people are checking in in real-time with vibe-based filtering
class LocationCheckInDiscoveryScreen extends StatefulWidget {
  const LocationCheckInDiscoveryScreen({super.key});

  @override
  State<LocationCheckInDiscoveryScreen> createState() =>
      _LocationCheckInDiscoveryScreenState();
}

class _LocationCheckInDiscoveryScreenState
    extends State<LocationCheckInDiscoveryScreen> {
  late GoogleMapController _mapController;
  Map<String, int>? _locations;
  Set<Marker> _markers = {};
  bool _loading = false;
  bool _showMap = true;
  final Set<String> _selectedVibes = {};
  Timer? _refreshTimer;

  // Sample coordinates
  static const Map<String, LatLng> _locationCoords = {
    'The Local Pub': LatLng(37.4310, -122.0840),
    'Downtown Coffee': LatLng(37.4270, -122.0850),
    'City Park': LatLng(37.4250, -122.0860),
    'Beach Club': LatLng(37.4200, -122.0900),
    'Tech Hub Cafe': LatLng(37.4350, -122.0800),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupAutoRefresh();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    try {
      final heatMap = await CheckInService.getLocationHeatMap();
      if (mounted) {
        setState(() {
          _locations = heatMap;
        });
        _updateMarkers();
      }
    } catch (e) {
      debugPrint('Error loading heat map: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _updateMarkers() {
    if (_locations == null) return;

    final newMarkers = <Marker>{};

    _locations!.forEach((locationName, count) {
      // If vibes selected, show all (filtering by vibe done on backend in production)
      final coords = _locationCoords[locationName];
      if (coords != null) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(locationName),
            position: coords,
            infoWindow: InfoWindow(
              title: locationName,
              snippet: '$count people checking in',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CheckInScreen(locationName: locationName),
                  ),
                );
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getHueForCount(count),
            ),
          ),
        );
      }
    });

    setState(() {
      _markers = newMarkers;
    });
  }

  Color _getHeatMapColor(int intensity) {
    if (intensity <= 5) return const Color(0xFF00D9FF); // Blue - chill
    if (intensity <= 15) return const Color(0xFFFFD60A); // Yellow - active
    if (intensity <= 30) return const Color(0xFFFF9500); // Orange - hot
    return const Color(0xFFFF006E); // Pink - party!
  }

  double _getHueForCount(int count) {
    if (count <= 5) return BitmapDescriptor.hueBlue;
    if (count <= 15) return BitmapDescriptor.hueYellow;
    if (count <= 30) return BitmapDescriptor.hueOrange;
    return BitmapDescriptor.hueRose;
  }

  List<Map<String, dynamic>> _getFilteredLocationsSorted() {
    if (_locations == null) return [];
    
    return _locations!.entries
        .map((e) => {'name': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Discovery'),
        elevation: 0,
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map or List View
          _showMap ? _buildMapView() : _buildListView(),

          // Loading overlay
          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Toggle button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                setState(() {
                  _showMap = !_showMap;
                });
              },
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              tooltip: _showMap ? 'List View' : 'Map View',
              child: Icon(_showMap ? Icons.list : Icons.map),
            ),
          ),

          // Vibe filter button
          Positioned(
            bottom: 76,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _showVibeFilter,
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              tooltip: 'Filter by Vibe',
              child: Stack(
                children: [
                  const Icon(Icons.filter_list),
                  if (_selectedVibes.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(37.4310, -122.0840),
        zoom: 13,
      ),
      markers: _markers,
      mapType: MapType.normal,
      zoomControlsEnabled: true,
      style: _darkMapStyle,
    );
  }

  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#746855"}]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [{"color": "#263c3f"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#17263c"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#515c6d"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#17263c"}]
    }
  ]
  ''';

  Widget _buildListView() {
    final sortedLocations = _getFilteredLocationsSorted();
    
    if (sortedLocations.isEmpty) {
      return const Center(
        child: Text(
          'No locations active yet',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedLocations.length,
      itemBuilder: (context, index) {
        final location = sortedLocations[index];
        final name = location['name'] as String;
        final count = location['count'] as int;
        final color = _getHeatMapColor(count);

        return Card(
          color: const Color(0xFF2A2A2A),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '$count ${count == 1 ? 'person' : 'people'} checking in',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(
              Icons.arrow_forward,
              color: Colors.white54,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckInScreen(locationName: name),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showVibeFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Vibe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedVibes.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedVibes.clear();
                      });
                      _updateMarkers();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CheckInService.getAvailableVibes().take(6).map((vibe) {
                final isSelected = _selectedVibes.contains(vibe);
                final emoji = MeengleCheckIn.getVibeEmoji(vibe);
                final colorHex = MeengleCheckIn.getVibeColor(vibe);
                final color = Color(int.parse(colorHex.replaceFirst('#', '0xff')));

                return FilterChip(
                  label: Text('$emoji $vibe'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedVibes.add(vibe);
                      } else {
                        _selectedVibes.remove(vibe);
                      }
                    });
                    _updateMarkers();
                  },
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                    color: isSelected ? color : Colors.white30,
                    width: 2,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? color : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
