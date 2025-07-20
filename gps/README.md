# GPS Tracker App

This Flutter app, created by Samudra Kashyap, connects to a GPS device (or uses the phone's GPS) to track and display the user's location on a map. It also allows users to view their route history.

## Functionality

The app provides the following features:

*   **Real-time location tracking:** The app tracks the user's location in real-time and displays it on a map using the `google_maps_flutter` package. The location is updated periodically using the `geolocator` package.
*   **Route display:** The app displays the user's route as a polyline on the map. The polyline is updated as the user moves.
*   **Location details:** The app displays the user's current latitude, longitude, and speed at the bottom of the screen.
*   **Local storage:** The app stores the user's location data in a local SQLite database using the `sqflite` package.
*   **Route history:** The app allows users to view their route history. Each route includes the start time, end time, and a list of locations. The route history is stored in the local SQLite database.
*   **Route replay:** When a user selects a route from the history, the app replays the route on the map, showing the user's past movements.
*   **Settings:** The app includes a settings screen where the user can toggle dark mode and enable/disable mock GPS data.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first time building a Flutter app:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter, view our online documentation:

- [Docs](https://docs.flutter.dev/)

For help on editing plugin code, refer to the [documentation](https://docs.flutter.dev/development/packages-and-plugins/developing-packages).


## Libraries Used

- `flutter`: For building the user interface.
- `google_maps_flutter`: For map integration.
- `geolocator`: For location services.
- `sqflite`: For local database storage.
- `provider`: For state management.
- `path`: For manipulating file paths.
- `permission_handler`: For handling permissions.
- `intl`: For internationalization support.

## Setup

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Obtain a Google Maps API key:** You'll need a Google Maps API key to use the map functionality. Obtain one from the [Google Cloud Platform Console](https://console.cloud.google.com/google/maps-apis/overview). Make sure to enable the "Maps SDK for Android" and "Maps SDK for iOS" for your key.

    *   **Android:** Add your API key to the `AndroidManifest.xml` file located in `android/app/src/main/`. Locate the `<application>` tag and add the following `<meta-data>` tag as a child:

        ```xml
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY"/>
        ```

        Replace `YOUR_API_KEY` with your actual API key.

    *   **iOS:** Add your API key to the `AppDelegate.swift` file located in `ios/Runner/`. Locate the `application` function and add the following code:

        ```swift
        GMSServices.provideAPIKey("YOUR_API_KEY")
        ```

        Replace `YOUR_API_KEY` with your actual API key.
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Build

To build the app for Android:

```bash
flutter build apk
```

To build the app for iOS:

```bash
flutter build ios

# Folder Structure

Here's the folder structure of the project:

```bash
gps/
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
├── README.md
├── android/
│   ├── .gitignore
│   ├── build.gradle
│   ├── gps_android.iml
│   ├── gradle.properties
│   ├── settings.gradle
│   ├── app/
│   └── gradle/
├── build/
├── flutter_gps_tracker/
├── ios/
│   ├── .gitignore
│   ├── Flutter/
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── RunnerTests/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   ├── utils/
│   └── widgets/
├── linux/
├── macos/
├── test/
├── web/
└── windows/