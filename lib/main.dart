import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const OtvorenoApp());
}

class OtvorenoApp extends StatelessWidget {
  const OtvorenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otvoreno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const MapHomeScreen(),
    );
  }
}

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({super.key});

  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  final MapController _mapController = MapController();

  LatLng? _userLocation;
  bool _loading = true;
  String? _error;

  final LatLng _defaultLocation = const LatLng(46.1608, 15.8789); // Krapina

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _error = 'Lokacija nije uključena na uređaju.';
          _loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _error = 'Dozvola za lokaciju nije odobrena.';
          _loading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = location;
        _loading = false;
      });

      _mapController.move(location, 14);
    } catch (e) {
      setState(() {
        _error = 'Greška kod dohvaćanja lokacije.';
        _loading = false;
      });
    }
  }

  void _centerOnUser() {
    final location = _userLocation ?? _defaultLocation;
    _mapController.move(location, 14);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = _userLocation ?? _defaultLocation;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.otvoreno.app',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: currentLocation,
                    radius: 1200,
                    color: Colors.green.withOpacity(0.12),
                    borderColor: Colors.green,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 18,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 12),
                    Text(
                      'Što tražiš?',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 230,
            child: FloatingActionButton(
              onPressed: _centerOnUser,
              child: const Icon(Icons.my_location),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.18,
            maxChildSize: 0.55,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 22,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Otvoreno?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_loading)
                      const Text('Tražim tvoju lokaciju...')
                    else if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      const Text(
                        'Lokacija pronađena. Sljedeće dodajemo trgovine u blizini.',
                      ),
                    const SizedBox(height: 20),
                    _CategoryRow(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Trgovine', Icons.shopping_cart),
      ('Ljekarne', Icons.local_hospital),
      ('Benzinske', Icons.local_gas_station),
      ('Pekare', Icons.bakery_dining),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((item) {
        return Chip(
          avatar: Icon(item.$2, size: 18),
          label: Text(item.$1),
        );
      }).toList(),
    );
  }
}