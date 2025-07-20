import 'package:geolocator/geolocator.dart';

class LocationData {
  final int? id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final int? routeId;

  LocationData({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.routeId,
  });

  factory LocationData.fromPosition(Position position, {int? routeId}) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      routeId: routeId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'routeId': routeId,
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      routeId: map['routeId'],
    );
  }
}
