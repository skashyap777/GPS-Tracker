import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import 'history_screen.dart';
import '../models/route_data.dart';
import 'settings_screen.dart';

Future<void> _ensurePermissions() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }
}

class MapScreen extends StatefulWidget {
  final RouteData? routeData;
  const MapScreen({super.key, this.routeData});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  void _updatePolyline() {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    if (locationService.currentRoute != null &&
        locationService.currentRoute!.locations != null) {
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: locationService.currentRoute!.locations!
                .map((loc) => LatLng(loc.latitude, loc.longitude))
                .toList(),
          ),
        );
      });
    }
  }

  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isTracking = false;
  StreamSubscription<Position>? _positionSubscription;

  void _updateMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: const InfoWindow(title: 'My Location'),
          ),
        );
      });
    }
  }

  void _startTracking() {
    _ensurePermissions().then((_) {
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      locationService.startTracking();
      _positionSubscription = locationService.positionStream.listen((position) {
        setState(() {
          _currentPosition = position;
          _updateMarker();
          _updatePolyline();
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude),
              ),
            );
          }
        });
      });
    });
  }

  void _stopTracking() {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    locationService.stopTracking();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    setState(() {
      _polylines.clear();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 150,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                if (_currentPosition != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                    ),
                  );
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Latitude: ${_currentPosition?.latitude ?? 0.0}'),
            Text('Longitude: ${_currentPosition?.longitude ?? 0.0}'),
            Text('Speed: ${(_currentPosition?.speed ?? 0.0) * 3.6} km/h'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isTracking = !_isTracking;
                  if (_isTracking) {
                    _startTracking();
                  } else {
                    _stopTracking();
                  }
                });
              },
              child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
