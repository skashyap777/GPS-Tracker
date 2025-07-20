// screens/route_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../widgets/route_replay_widget.dart';
import '../models/route_data.dart'; // Explicitly re-import RouteData

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({super.key});

  @override
  _RouteHistoryScreenState createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  List<RouteData> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final routes = await locationService.getRouteHistory();
    setState(() {
      _routes = routes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route History'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _routes.isEmpty
              ? Center(
                  child: Text(
                    'No routes found',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    final route = _routes[index];
                    final timestamp = route.startTime;

                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: Icon(Icons.route),
                        title: Text('Route ${index + 1}'),
                        subtitle: Text(
                          'Start: ${DateFormat('MMM dd, yyyy - HH:mm').format(route.startTime)}\n'
                          'End: ${route.endTime != null ? DateFormat('MMM dd, yyyy - HH:mm').format(route.endTime!) : 'N/A'}',
                        ),
                        trailing: Icon(Icons.play_arrow),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RouteReplayWidget(
                                route: route,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
