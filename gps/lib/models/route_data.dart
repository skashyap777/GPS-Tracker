import 'location_data.dart';

class RouteData {
  final int? id;
  final String? name;
  final DateTime startTime;
  DateTime? endTime;
  final double? distance;
  final List<LocationData>? locations;

  RouteData({
    this.id,
    this.name,
    required this.startTime,
    this.endTime,
    this.distance,
    this.locations,
  });

  RouteData copyWith({
    int? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    double? distance,
    List<LocationData>? locations,
  }) {
    return RouteData(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
      locations: locations ?? this.locations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'distance': distance,
    };
  }

  factory RouteData.fromMap(Map<String, dynamic> map,
      {List<LocationData>? locations}) {
    return RouteData(
      id: map['id'],
      name: map['name'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: map['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      distance: map['distance'],
      locations: locations,
    );
  }
}
