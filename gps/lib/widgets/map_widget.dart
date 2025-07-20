import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/route_data.dart';

class MapWidget extends StatefulWidget {
  final Position? currentLocation;
  final RouteData? currentRoute;

  const MapWidget({
    super.key, // Changed to super.key
    this.currentLocation,
    this.currentRoute,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {}; // Made final
  final Set<Marker> _markers = {}; // Made final
  final bool _isLoading = true;

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMap();
  }

  void _updateMap() {
    _polylines.clear();
    _markers.clear();

    if (widget.currentRoute != null && widget.currentRoute!.locations != null) {
      final routeLocations = widget.currentRoute!.locations!;
      if (routeLocations.isNotEmpty) {
        final polylinePoints = routeLocations
            .map((loc) => LatLng(loc.latitude, loc.longitude))
            .toList();

        _polylines.add(
          Polyline(
            polylineId: PolylineId(widget.currentRoute!.id.toString()),
            points: polylinePoints,
            color: Colors.blue,
            width: 5,
          ),
        );

        // Add start marker
        _markers.add(
          Marker(
            markerId: MarkerId('start_location'),
            position: LatLng(
                routeLocations.first.latitude, routeLocations.first.longitude),
            infoWindow: InfoWindow(title: 'Start'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        );

        // Add end marker
        _markers.add(
          Marker(
            markerId: MarkerId('end_location'),
            position: LatLng(
                routeLocations.last.latitude, routeLocations.last.longitude),
            infoWindow: InfoWindow(title: 'End'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }

    if (widget.currentLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(widget.currentLocation!.latitude,
              widget.currentLocation!.longitude),
          infoWindow: InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.currentLocation!.latitude,
              widget.currentLocation!.longitude),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.currentLocation != null
                  ? LatLng(widget.currentLocation!.latitude,
                      widget.currentLocation!.longitude)
                  : const LatLng(0, 0), // Default to 0,0 if no location
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _updateMap();
            },
            polylines: _polylines,
            markers: _markers,
          );
  }
}
