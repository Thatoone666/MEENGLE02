import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meengle_flutter/screens/checkin_screen.dart';

class NearbyLocationsScreen extends StatefulWidget {
  const NearbyLocationsScreen({super.key});

  @override
  State<NearbyLocationsScreen> createState() => _NearbyLocationsScreenState();
}

class _NearbyLocationsScreenState extends State<NearbyLocationsScreen> {
  bool _loading = true;
  String? _error;
  List<String> _locations = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _error = 'Location services are disabled.';
        _loading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'Location permissions are denied';
          _loading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _error =
            'Location permissions are permanently denied, we cannot request permissions.';
        _loading = false;
      });
      return;
    }

    // For this demo, we'll just use a hardcoded list of locations.
    // In a real app, you would use the user's position to query a places API.
    setState(() {
      _locations = [
        'The Local Pub',
        'Downtown Coffee',
        'City Park',
        'Rooftop Bar',
        'The Grand Library',
      ];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Locations'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    return ListTile(
                      title: Text(location),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CheckInScreen(locationName: location),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
