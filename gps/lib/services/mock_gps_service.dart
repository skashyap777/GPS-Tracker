import 'dart:async';
import 'package:geolocator/geolocator.dart';

class MockGpsService {
  final _positionStreamController = StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _positionStreamController.stream;

  MockGpsService() {
    _generateMockLocations();
  }

  void _generateMockLocations() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      final mockPosition = Position(
        latitude: 37.7749 + (timer.tick * 0.0001),
        longitude: -122.4194 + (timer.tick * 0.0001),
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 100.0,
        heading: 0.0,
        speed: 5.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0, // Add this
        headingAccuracy: 0.0, // Add this
      );
      _positionStreamController.add(mockPosition);
    });
  }

  void dispose() {
    _positionStreamController.close();
  }
}
