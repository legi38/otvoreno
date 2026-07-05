import 'dart:math' as math;

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

enum StoreCategory {
  all('Sve', Icons.apps),
  shops('Trgovine', Icons.shopping_cart),
  pharmacies('Ljekarne', Icons.local_hospital),
  gas('Benzinske', Icons.local_gas_station),
  bakeries('Pekare', Icons.bakery_dining);

  const StoreCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class StorePlace {
  const StorePlace({
    required this.id,
    required this.name,
    required this.position,
    required this.category,
    required this.isOpen,
    required this.openUntil,
    required this.address,
  });

  final String id;
  final String name;
  final LatLng position;
  final StoreCategory category;
  final bool isOpen;
  final String openUntil;
  final String address;
}

class StoreWithDistance {
  const StoreWithDistance(this.store, this.distanceMeters);
  final StorePlace store;
  final double distanceMeters;
}

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({super.key});

  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _userLocation;
  bool _loading = true;
  String? _error;
  StoreCategory _selectedCategory = StoreCategory.all;
  String _query = '';
  StorePlace? _selectedStore;

  final LatLng _defaultLocation = const LatLng(46.1608, 15.8789); // Krapina

  final List<StorePlace> _stores = const [
    StorePlace(
      id: 'lidl-krapina',
      name: 'Lidl Krapina',
      position: LatLng(46.1569, 15.8737),
      category: StoreCategory.shops,
      isOpen: true,
      openUntil: '21:00',
      address: 'Krapina',
    ),
    StorePlace(
      id: 'konzum-krapina',
      name: 'Konzum Krapina',
      position: LatLng(46.1616, 15.8769),
      category: StoreCategory.shops,
      isOpen: true,
      openUntil: '20:00',
      address: 'Krapina',
    ),
    StorePlace(
      id: 'spar-krapina',
      name: 'Spar Krapina',
      position: LatLng(46.1644, 15.8732),
      category: StoreCategory.shops,
      isOpen: false,
      openUntil: '08:00',
      address: 'Krapina',
    ),
    StorePlace(
      id: 'plodine-krapina',
      name: 'Plodine Krapina',
      position: LatLng(46.1539, 15.8838),
      category: StoreCategory.shops,
      isOpen: true,
      openUntil: '22:00',
      address: 'Krapina',
    ),
    StorePlace(
      id: 'ljekarna-krapina',
      name: 'Ljekarna Krapina',
      position: LatLng(46.1601, 15.8785),
      category: StoreCategory.pharmacies,
      isOpen: true,
      openUntil: '19:00',
      address: 'Centar Krapina',
    ),
    StorePlace(
      id: 'pekara-aroma',
      name: 'Pekara Aroma',
      position: LatLng(46.1585, 15.8802),
      category: StoreCategory.bakeries,
      isOpen: true,
      openUntil: '18:00',
      address: 'Krapina',
    ),
    StorePlace(
      id: 'ina-krapina',
      name: 'INA Krapina',
      position: LatLng(46.1665, 15.8709),
      category: StoreCategory.gas,
      isOpen: true,
      openUntil: '24:00',
      address: 'Krapina',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    } catch (_) {
      setState(() {
        _error = 'Greška kod dohvaćanja lokacije.';
        _loading = false;
      });
    }
  }

  List<StoreWithDistance> get _visibleStores {
    final base = _userLocation ?? _defaultLocation;
    final distance = const Distance();

    final items = _stores
        .where((store) {
          final matchesCategory = _selectedCategory == StoreCategory.all ||
              store.category == _selectedCategory;
          final text = '${store.name} ${store.category.label}'.toLowerCase();
          final matchesQuery = _query.trim().isEmpty ||
              text.contains(_query.trim().toLowerCase());
          return matchesCategory && matchesQuery;
        })
        .map((store) => StoreWithDistance(store, distance(base, store.position)))
        .toList();

    items.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return items;
  }

  void _centerOnUser() {
    final location = _userLocation ?? _defaultLocation;
    _mapController.move(location, 14);
  }

  void _selectStore(StorePlace store) {
    setState(() => _selectedStore = store);
    _mapController.move(store.position, 15.5);
  }

  String _distanceText(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = _userLocation ?? _defaultLocation;
    final visibleStores = _visibleStores;

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
                    color: Colors.green.withValues(alpha: 0.12),
                    borderColor: Colors.green,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  ...visibleStores.map(
                    (item) => Marker(
                      point: item.store.position,
                      width: 54,
                      height: 54,
                      child: GestureDetector(
                        onTap: () => _selectStore(item.store),
                        child: _StoreMarker(
                          store: item.store,
                          selected: _selectedStore?.id == item.store.id,
                        ),
                      ),
                    ),
                  ),
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
                          BoxShadow(blurRadius: 12, color: Colors.black26),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SearchBox(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: StoreCategory.values.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: _selectedCategory == category,
                            avatar: Icon(category.icon, size: 18),
                            label: Text(category.label),
                            onSelected: (_) {
                              setState(() => _selectedCategory = category);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 250,
            child: FloatingActionButton(
              onPressed: _centerOnUser,
              child: const Icon(Icons.my_location),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.31,
            minChildSize: 0.18,
            maxChildSize: 0.72,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: const [
                    BoxShadow(blurRadius: 22, color: Colors.black26),
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Mjesta u blizini',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text('${visibleStores.length}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_loading)
                      const Text('Tražim tvoju lokaciju...')
                    else if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red))
                    else
                      const Text('Prikazujemo testne lokacije za Sprint 3.'),
                    const SizedBox(height: 14),
                    if (visibleStores.isEmpty)
                      const _EmptyState()
                    else
                      ...visibleStores.map(
                        (item) => _StoreCard(
                          item: item,
                          selected: _selectedStore?.id == item.store.id,
                          distanceText: _distanceText(item.distanceMeters),
                          onTap: () => _selectStore(item.store),
                        ),
                      ),
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

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(blurRadius: 18, color: Colors.black26)],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Što tražiš?',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _StoreMarker extends StatelessWidget {
  const _StoreMarker({required this.store, required this.selected});

  final StorePlace store;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = store.isOpen ? Colors.green : Colors.red;
    return AnimatedScale(
      scale: selected ? 1.18 : 1,
      duration: const Duration(milliseconds: 180),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
        ),
        child: Icon(store.category.icon, color: Colors.white, size: 25),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.item,
    required this.selected,
    required this.distanceText,
    required this.onTap,
  });

  final StoreWithDistance item;
  final bool selected;
  final String distanceText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final store = item.store;
    final statusColor = store.isOpen ? Colors.green : Colors.red;
    final statusText = store.isOpen
        ? 'Otvoreno do ${store.openUntil}'
        : 'Zatvoreno · otvara u ${store.openUntil}';

    return Card(
      elevation: selected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: selected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.12),
                child: Icon(store.category.icon, color: statusColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('$distanceText · ${store.address}'),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Navigacija',
                onPressed: () {},
                icon: Transform.rotate(
                  angle: -math.pi / 4,
                  child: const Icon(Icons.navigation),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Text('Nema rezultata za odabrani filter.'),
      ),
    );
  }
}
