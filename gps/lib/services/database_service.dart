import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/location_data.dart';
import '../models/route_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gps_tracker.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE routes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        startTime INTEGER,
        endTime INTEGER,
        distance REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE locations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL,
        longitude REAL,
        timestamp INTEGER,
        routeId INTEGER,
        FOREIGN KEY (routeId) REFERENCES routes(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("PRAGMA foreign_keys=off;");
      await db.execute("BEGIN TRANSACTION;");

      await db.execute("ALTER TABLE routes RENAME TO old_routes;");
      await db.execute('''
        CREATE TABLE routes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          startTime INTEGER,
          endTime INTEGER,
          distance REAL
        )
      ''');
      await db.execute(
          "INSERT INTO routes(id, startTime, endTime, distance) SELECT id, startTime, endTime, distance FROM old_routes;");
      await db.execute("DROP TABLE old_routes;");

      await db.execute("ALTER TABLE locations RENAME TO old_locations;");
      await db.execute('''
        CREATE TABLE locations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL,
          longitude REAL,
          timestamp INTEGER,
          routeId INTEGER,
          FOREIGN KEY (routeId) REFERENCES routes(id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
          "INSERT INTO locations(id, latitude, longitude, timestamp, routeId) SELECT id, latitude, longitude, timestamp, routeId FROM old_locations;");
      await db.execute("DROP TABLE old_locations;");

      await db.execute("COMMIT;");
      await db.execute("PRAGMA foreign_keys=on;");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE routes ADD COLUMN name TEXT;");
    }
  }

  Future<int> insertLocation(LocationData location) async {
    Database db = await database;
    return await db.insert('locations', location.toMap());
  }

  Future<int> insertRoute(RouteData route) async {
    Database db = await database;
    return await db.insert('routes', route.toMap());
  }

  Future<void> updateRouteName(int id, String name) async {
    Database db = await database;
    await db.update(
      'routes',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteRoute(int id) async {
    Database db = await database;
    await db.delete(
      'routes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocationData>> getLocationsForRoute(int routeId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'locations',
      where: 'routeId = ?',
      whereArgs: [routeId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) {
      return LocationData.fromMap(maps[i]);
    });
  }

  Future<List<RouteData>> getRouteHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> routesMaps =
        await db.query('routes', orderBy: 'startTime DESC');

    if (routesMaps.isEmpty) {
      return [];
    }

    final List<RouteData> routes = [];
    for (var routeMap in routesMaps) {
      final routeId = routeMap['id'] as int;
      final locationsMaps = await db.query(
        'locations',
        where: 'routeId = ?',
        whereArgs: [routeId],
        orderBy: 'timestamp ASC',
      );

      final locations = locationsMaps
          .map((locationMap) => LocationData.fromMap(locationMap))
          .toList();

      routes.add(RouteData.fromMap(routeMap, locations: locations));
    }

    return routes;
  }

  Future<void> updateRouteEndTime(int id, DateTime endTime) async {
    Database db = await database;
    await db.update(
      'routes',
      {'endTime': endTime.millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
