import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                title: const Text('Use Mock GPS'),
                trailing: Switch(
                  value: settings.useMockGps,
                  onChanged: (value) {
                    settings.toggleMockGps();
                  },
                ),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: settings.isDarkMode,
                  onChanged: (value) {
                    settings.toggleDarkMode();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
