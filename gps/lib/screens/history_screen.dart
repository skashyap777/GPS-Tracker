import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/route_data.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/route_replay_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<RouteData>>? _routeHistory;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _routeHistory = Provider.of<DatabaseService>(context, listen: false)
          .getRouteHistory();
    });
  }

  Future<void> _renameRoute(RouteData route) async {
    final nameController = TextEditingController(text: route.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Route'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await Provider.of<DatabaseService>(context, listen: false)
          .updateRouteName(route.id!, newName);
      _loadHistory();
    }
  }

  Future<void> _deleteRoute(RouteData route) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: const Text('Are you sure you want to delete this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Provider.of<DatabaseService>(context, listen: false)
          .deleteRoute(route.id!);
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: FutureBuilder<List<RouteData>>(
        future: _routeHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final routes = snapshot.data!;
            return ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                final locs = route.locations;

                String start = 'N/A';
                String end = 'N/A';
                String distanceStr = 'N/A';

                if (locs != null && locs.isNotEmpty) {
                  start =
                      '${locs.first.latitude.toStringAsFixed(5)}, ${locs.first.longitude.toStringAsFixed(5)}';
                  end =
                      '${locs.last.latitude.toStringAsFixed(5)}, ${locs.last.longitude.toStringAsFixed(5)}';

                  double totalDistance = 0.0;
                  for (int i = 1; i < locs.length; i++) {
                    totalDistance += Geolocator.distanceBetween(
                      locs[i - 1].latitude,
                      locs[i - 1].longitude,
                      locs[i].latitude,
                      locs[i].longitude,
                    );
                  }
                  distanceStr =
                      '${(totalDistance / 1000).toStringAsFixed(2)} km';
                }

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: InkWell(
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Rename'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _renameRoute(route);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Delete'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _deleteRoute(route);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.name ?? 'Route ${route.id}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('From:', start),
                          _buildInfoRow('To:', end),
                          _buildInfoRow(
                              'Start Time:', route.startTime.toString()),
                          _buildInfoRow(
                              'End Time:', route.endTime?.toString() ?? 'N/A'),
                          _buildInfoRow('Distance:', distanceStr),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.play_arrow,
                                  color: Colors.blue, size: 30),
                              tooltip: 'Replay Route',
                              onPressed: () {
                                if (route.locations != null &&
                                    route.locations!.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RouteReplayWidget(route: route),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No routes found'));
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
