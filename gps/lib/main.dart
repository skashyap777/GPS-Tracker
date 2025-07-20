// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/location_service.dart';
import 'services/database_service.dart';
import 'services/mock_gps_service.dart';
import 'providers/settings_provider.dart'; // Import the new provider

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Declare SettingsProvider first
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
        // Now, access SettingsProvider to configure LocationService
        ChangeNotifierProxyProvider<SettingsProvider, LocationService>(
          create: (context) => LocationService(),
          update: (context, settings, locationService) {
            return LocationService(
              positionStream: settings.useMockGps
                  ? MockGpsService().positionStream
                  : null, // Pass null to use default Geolocator stream
            );
          },
        ),
        Provider(create: (_) => DatabaseService()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'GPS Tracker',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
