import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/location_data.dart';
import '../models/route_data.dart';
import '../services/database_service.dart';

class RouteReplayWidget extends StatefulWidget {
  final RouteData route;

  const RouteReplayWidget({super.key, required this.route});

  @override
  _RouteReplayWidgetState createState() => _RouteReplayWidgetState();
}

class _RouteReplayWidgetState extends State<RouteReplayWidget> {
  GoogleMapController? _mapController;
  List<LocationData> _routeData = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isPlaying = false;
  Timer? _replayTimer;

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  @override
  void dispose() {
    _replayTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRouteData() async {
    List<LocationData> locs = widget.route.locations ?? [];
    if (locs.isEmpty && widget.route.id != null) {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      locs = await dbService.getLocationsForRoute(widget.route.id!);
    }
    setState(() {
      _routeData = locs;
      _isLoading = false;
    });
    if (_routeData.isNotEmpty) {
      _initializeMap();
    }
  }

  void _initializeMap() {
    List<LatLng> polylinePoints = _routeData
        .map((location) => LatLng(location.latitude, location.longitude))
        .toList();

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylinePoints,
        color: Colors.blue,
        width: 5,
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(_routeData.first.latitude, _routeData.first.longitude),
        infoWindow: const InfoWindow(title: 'Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('end'),
        position: LatLng(_routeData.last.latitude, _routeData.last.longitude),
        infoWindow: const InfoWindow(title: 'End'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    setState(() {});
  }

  void _toggleReplay() {
    if (_isPlaying) {
      _pauseReplay();
    } else {
      _startReplay();
    }
  }

  void _startReplay() {
    if (_routeData.isEmpty) return;

    setState(() {
      _isPlaying = true;
      if (_currentIndex >= _routeData.length - 1) {
        _currentIndex = 0;
        _markers.removeWhere((m) => m.markerId.value == 'current');
      }
    });

    _replayTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentIndex < _routeData.length) {
        _replayStep();
      } else {
        _pauseReplay();
      }
    });
  }

  void _pauseReplay() {
    _replayTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

  void _replayStep() {
    final currentLocation = _routeData[_currentIndex];
    final latLng = LatLng(currentLocation.latitude, currentLocation.longitude);

    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'current');
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Current Position'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
      _currentIndex++;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Replay'),
        actions: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleReplay,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _routeData.isEmpty
              ? const Center(child: Text('No route data available'))
              : Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                          if (_routeData.isNotEmpty) {
                            controller.animateCamera(
                              CameraUpdate.newLatLngBounds(
                                _calculateBounds(),
                                100,
                              ),
                            );
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: _routeData.isNotEmpty
                              ? LatLng(_routeData.first.latitude,
                                  _routeData.first.longitude)
                              : const LatLng(37.7749, -122.4194),
                          zoom: 15,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_routeData.isNotEmpty) ...[
                            Text(
                              'Progress: $_currentIndex/${_routeData.length}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _routeData.isNotEmpty
                                  ? _currentIndex / _routeData.length
                                  : 0,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  LatLngBounds _calculateBounds() {
    if (_routeData.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(37.7749, -122.4194),
        northeast: const LatLng(37.7749, -122.4194),
      );
    }

    double minLat = _routeData.first.latitude;
    double maxLat = _routeData.first.latitude;
    double minLng = _routeData.first.longitude;
    double maxLng = _routeData.first.longitude;

    for (var location in _routeData) {
      minLat = minLat < location.latitude ? minLat : location.latitude;
      maxLat = maxLat > location.latitude ? maxLat : location.latitude;
      minLng = minLng < location.longitude ? minLng : location.longitude;
      maxLng = maxLng > location.longitude ? maxLng : location.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
