import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/location/location_service.dart';
import '../../../shared/models/store_category.dart';
import '../../../shared/models/store_place.dart';
import '../../../shared/models/store_with_distance.dart';
import '../data/store_repository.dart';
import 'widgets/category_filters.dart';
import 'widgets/location_button.dart';
import 'widgets/map_bottom_sheet.dart';
import 'widgets/search_box.dart';
import 'widgets/store_marker.dart';

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({super.key});

  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _locationService = LocationService();
  final _storeRepository = OverpassStoreRepository();

  LatLng? _userLocation;
  bool _locationLoading = true;
  bool _storesLoading = false;
  String? _locationError;
  String? _storesError;
  StoreCategory _selectedCategory = StoreCategory.all;
  String _query = '';
  StorePlace? _selectedStore;
  List<StoreWithDistance> _visibleStores = const [];

  LatLng get _currentLocation => _userLocation ?? AppConstants.defaultLocation;

  @override
  void initState() {
    super.initState();
    _loadLocationAndStores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationAndStores() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });

    final result = await _locationService.getCurrentLocation();

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _userLocation = result.location;
        _locationLoading = false;
      });
      _mapController.move(result.location!, 14);
    } else {
      setState(() {
        _locationError = result.error;
        _locationLoading = false;
      });
    }

    await _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      _storesLoading = true;
      _storesError = null;
      _selectedStore = null;
    });

    try {
      final stores = await _storeRepository.searchStores(
        userLocation: _currentLocation,
        category: _selectedCategory,
        query: _query,
      );

      if (!mounted) return;
      setState(() {
        _visibleStores = stores;
        _storesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _storesError = 'Ne mogu dohvatiti mjesta. Provjeri internet i pokušaj ponovno.';
        _storesLoading = false;
      });
    }
  }

  void _centerOnUser() {
    _mapController.move(_currentLocation, 14);
  }

  void _selectStore(StorePlace store) {
    setState(() => _selectedStore = store);
    _mapController.move(store.position, 15.5);
  }

  Future<void> _changeCategory(StoreCategory category) async {
    setState(() => _selectedCategory = category);
    await _loadStores();
  }

  Future<void> _changeQuery(String value) async {
    setState(() => _query = value);
    await _loadStores();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _locationLoading || _storesLoading;
    final error = _locationError ?? _storesError;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: AppConstants.osmUserAgent,
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _currentLocation,
                    radius: 1200,
                    color: Colors.green.withValues(alpha: 0.12),
                    borderColor: Colors.green,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  ..._visibleStores.map(
                    (item) => Marker(
                      point: item.store.position,
                      width: 54,
                      height: 54,
                      child: GestureDetector(
                        onTap: () => _selectStore(item.store),
                        child: StoreMarker(
                          store: item.store,
                          selected: _selectedStore?.id == item.store.id,
                        ),
                      ),
                    ),
                  ),
                  Marker(
                    point: _currentLocation,
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
                  SearchBox(
                    controller: _searchController,
                    onChanged: _changeQuery,
                  ),
                  const SizedBox(height: 10),
                  CategoryFilters(
                    selectedCategory: _selectedCategory,
                    onSelected: _changeCategory,
                  ),
                ],
              ),
            ),
          ),
          LocationButton(onPressed: _centerOnUser),
          MapBottomSheet(
            loading: isLoading,
            error: error,
            visibleStores: _visibleStores,
            selectedStore: _selectedStore,
            onStoreTap: _selectStore,
            onRetry: _loadStores,
          ),
        ],
      ),
    );
  }
}
