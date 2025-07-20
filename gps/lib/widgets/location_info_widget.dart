import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/route_data.dart';
import 'package:intl/intl.dart';

class LocationInfoWidget extends StatelessWidget {
  final Position? currentLocation;
  final bool isTracking;
  final RouteData? currentRoute;

  const LocationInfoWidget({
    super.key,
    this.currentLocation,
    required this.isTracking,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status: ${isTracking ? 'Tracking' : 'Not Tracking'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Latitude: ${currentLocation?.latitude.toStringAsFixed(6) ?? 'N/A'}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Longitude: ${currentLocation?.longitude.toStringAsFixed(6) ?? 'N/A'}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Altitude: ${currentLocation?.altitude.toStringAsFixed(2) ?? 'N/A'} m',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Speed: ${currentLocation?.speed.toStringAsFixed(2) ?? 'N/A'} m/s',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (currentRoute != null)
            Text(
              'Route Start: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(currentRoute!.startTime)}',
              style: const TextStyle(fontSize: 16),
            ),
          if (currentRoute != null && currentRoute!.endTime != null)
            Text(
              'Route End: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(currentRoute!.endTime!)}',
              style: const TextStyle(fontSize: 16),
            ),
          if (currentRoute != null && currentRoute!.locations != null)
            Text(
              'Locations Recorded: ${currentRoute!.locations!.length}',
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}
