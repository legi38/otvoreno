import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../shared/models/store_category.dart';
import '../../../shared/models/store_place.dart';
import '../../../shared/models/store_with_distance.dart';

abstract class StoreRepository {
  Future<List<StoreWithDistance>> searchStores({
    required LatLng userLocation,
    required StoreCategory category,
    required String query,
  });
}

class OverpassStoreRepository implements StoreRepository {
  OverpassStoreRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _radiusMeters = 5000;
  static final _endpoint = Uri.parse('https://overpass-api.de/api/interpreter');

  @override
  Future<List<StoreWithDistance>> searchStores({
    required LatLng userLocation,
    required StoreCategory category,
    required String query,
  }) async {
    final overpassQuery = _buildQuery(userLocation: userLocation, category: category);

    final response = await _client
        .post(
          _endpoint,
          headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
          body: {'data': overpassQuery},
        )
        .timeout(const Duration(seconds: 18));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Overpass API greška: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = (decoded['elements'] as List<dynamic>? ?? const []);

    final distance = const Distance();
    final normalizedQuery = query.trim().toLowerCase();
    final seen = <String>{};

    final stores = elements
        .map((element) => _parseElement(element as Map<String, dynamic>))
        .whereType<StorePlace>()
        .where((store) => seen.add(store.id))
        .where((store) {
          if (normalizedQuery.isEmpty) return true;
          final searchable = '${store.name} ${store.address} ${store.category.label}'.toLowerCase();
          return searchable.contains(normalizedQuery);
        })
        .map(
          (store) => StoreWithDistance(
            store: store,
            distanceMeters: distance(userLocation, store.position),
          ),
        )
        .toList();

    stores.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return stores.take(60).toList();
  }

  String _buildQuery({required LatLng userLocation, required StoreCategory category}) {
    final lat = userLocation.latitude;
    final lon = userLocation.longitude;
    final filters = _filtersForCategory(category);

    final blocks = filters.map((filter) {
      return '''
        node$filter(around:$_radiusMeters,$lat,$lon);
        way$filter(around:$_radiusMeters,$lat,$lon);
        relation$filter(around:$_radiusMeters,$lat,$lon);
      ''';
    }).join('\n');

    return '''
      [out:json][timeout:18];
      (
        $blocks
      );
      out center tags 80;
    ''';
  }

  List<String> _filtersForCategory(StoreCategory category) {
    switch (category) {
      case StoreCategory.shops:
        return ['["shop"~"supermarket|convenience|department_store|mall|general"]'];
      case StoreCategory.pharmacies:
        return ['["amenity"="pharmacy"]'];
      case StoreCategory.gas:
        return ['["amenity"="fuel"]'];
      case StoreCategory.bakeries:
        return ['["shop"="bakery"]'];
      case StoreCategory.all:
        return [
          '["shop"~"supermarket|convenience|department_store|mall|general|bakery"]',
          '["amenity"~"pharmacy|fuel"]',
        ];
    }
  }

  StorePlace? _parseElement(Map<String, dynamic> element) {
    final tags = (element['tags'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final name = (tags['name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;

    final lat = (element['lat'] as num?)?.toDouble() ??
        ((element['center'] as Map?)?['lat'] as num?)?.toDouble();
    final lon = (element['lon'] as num?)?.toDouble() ??
        ((element['center'] as Map?)?['lon'] as num?)?.toDouble();

    if (lat == null || lon == null) return null;

    final id = '${element['type']}-${element['id']}';
    final category = _categoryFromTags(tags);
    final address = _addressFromTags(tags);

    return StorePlace(
      id: id,
      name: name,
      position: LatLng(lat, lon),
      category: category,
      address: address,
      openingHours: tags['opening_hours'] as String?,
      openStatus: StoreOpenStatus.unknown,
      source: 'OpenStreetMap',
    );
  }

  StoreCategory _categoryFromTags(Map<String, dynamic> tags) {
    if (tags['amenity'] == 'pharmacy') return StoreCategory.pharmacies;
    if (tags['amenity'] == 'fuel') return StoreCategory.gas;
    if (tags['shop'] == 'bakery') return StoreCategory.bakeries;
    return StoreCategory.shops;
  }

  String _addressFromTags(Map<String, dynamic> tags) {
    final street = tags['addr:street'];
    final houseNumber = tags['addr:housenumber'];
    final city = tags['addr:city'];

    final streetPart = [street, houseNumber]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(' ');

    final parts = [streetPart, city]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'Adresa nije dostupna';
    return parts.join(', ');
  }
}
