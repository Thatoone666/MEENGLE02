import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meengle_flutter/services/checkin_service.dart';
import 'package:meengle_flutter/screens/checkin_screen.dart';

class LocationsMapScreen extends StatefulWidget {
  const LocationsMapScreen({super.key});

  @override
  State<LocationsMapScreen> createState() => _LocationsMapScreenState();
}

class _LocationsMapScreenState extends State<LocationsMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  bool _loading = true;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _fetchCheckinData();
  }

  Future<void> _fetchCheckinData() async {
    // In a real app, you'd fetch all locations with active check-ins
    // and their coordinates. For this demo, we'll use a hardcoded list.
    final locations = {
      'The Local Pub': const LatLng(37.4310, -122.0840),
      'Downtown Coffee': const LatLng(37.4270, -122.0850),
      'City Park': const LatLng(37.4250, -122.0860),
    };

    final markers = <Marker>{};

    for (var locationName in locations.keys) {
      try {
        final checkIns = await CheckInService.getCheckIns(locationName);
        if (checkIns != null && checkIns.isNotEmpty) {
          markers.add(
            Marker(
              markerId: MarkerId(locationName),
              position: locations[locationName]!,
              infoWindow: InfoWindow(
                title: locationName,
                snippet: '${checkIns.length} people checked in',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          CheckInScreen(locationName: locationName),
                    ),
                  );
                },
              ),
            ),
          );
        }
      } catch (e) {
        // Ignore errors for individual locations for now
      }
    }

    setState(() {
      _markers = markers;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations Map'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            )
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
      ),
    );
  }
}
