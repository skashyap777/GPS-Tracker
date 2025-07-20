import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_service.dart';
import '../models/location_data.dart';
import '../models/route_data.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTracking = false;
  RouteData? _currentRoute;
  final DatabaseService _dbService = DatabaseService();
  final Stream<Position> _positionStream;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  RouteData? get currentRoute => _currentRoute;
  Stream<Position> get positionStream => _positionStream;

  LocationService({Stream<Position>? positionStream})
      : _positionStream = positionStream ??
            Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 10,
              ),
            ) {
    _init();
  }

  Future<void> _init() async {
    await _positionStreamSubscription?.cancel();
    await _requestPermission();
    if (await Permission.location.isGranted) {
      _positionStreamSubscription = _positionStream.listen((Position position) {
        _currentPosition = position;
        if (_isTracking) {
          _recordLocation(position);
        }
        notifyListeners();
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      // Handle permission denied
    } else if (status.isPermanentlyDenied) {
      // Handle permanently denied
      openAppSettings();
    }
  }

  void _recordLocation(Position position) {
    if (_currentRoute != null) {
      final location = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        routeId: _currentRoute!.id,
      );
      _dbService.insertLocation(location);
      _currentRoute = _currentRoute!.copyWith(
        locations: [..._currentRoute!.locations ?? [], location],
      );
    }
  }

  Future<void> startTracking() async {
    if (await Permission.location.isGranted) {
      _isTracking = true;
      _currentRoute = RouteData(startTime: DateTime.now(), locations: []);
      _currentRoute = _currentRoute!.copyWith(
        id: await _dbService.insertRoute(_currentRoute!),
      );
      notifyListeners();
    } else {
      await _requestPermission();
    }
  }

  void stopTracking() async {
    _isTracking = false;
    if (_currentRoute != null) {
      _currentRoute!.endTime = DateTime.now();
      await _dbService.updateRouteEndTime(
          _currentRoute!.id!, _currentRoute!.endTime!);
    }
    _currentRoute = null;
    notifyListeners();
  }

  Future<List<RouteData>> getRouteHistory() {
    return _dbService.getRouteHistory();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
