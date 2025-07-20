import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../widgets/location_info_widget.dart';
import '../widgets/map_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Tracker'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MapWidget(
              currentLocation: locationService.currentPosition,
              currentRoute: locationService.currentRoute,
            ),
          ),
          Expanded(
            flex: 1,
            child: LocationInfoWidget(
              currentLocation: locationService.currentPosition,
              isTracking: locationService.isTracking,
              currentRoute: locationService.currentRoute,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: locationService.isTracking
                      ? locationService.stopTracking
                      : locationService.startTracking,
                  child: Text(locationService.isTracking
                      ? 'Stop Tracking'
                      : 'Start Tracking'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/history');
                  },
                  child: const Text('View History'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
