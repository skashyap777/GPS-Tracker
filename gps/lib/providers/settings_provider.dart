import 'package:flutter/foundation.dart';

class SettingsProvider with ChangeNotifier {
  bool _useMockGps = false; // Default to using actual GPS
  bool _isDarkMode = false;

  bool get useMockGps => _useMockGps;
  bool get isDarkMode => _isDarkMode;

  void toggleMockGps() {
    _useMockGps = !_useMockGps;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Method to set the initial state if needed, e.g., from saved preferences
  void setMockGps(bool value) {
    _useMockGps = value;
    notifyListeners();
  }
}
