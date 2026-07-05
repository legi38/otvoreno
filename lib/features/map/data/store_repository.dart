import 'package:latlong2/latlong.dart';

import '../../../shared/models/store_category.dart';
import '../../../shared/models/store_place.dart';
import '../../../shared/models/store_with_distance.dart';

abstract class StoreRepository {
  List<StoreWithDistance> searchStores({
    required LatLng userLocation,
    required StoreCategory category,
    required String query,
  });
}

class MockStoreRepository implements StoreRepository {
  static const _stores = [
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
  List<StoreWithDistance> searchStores({
    required LatLng userLocation,
    required StoreCategory category,
    required String query,
  }) {
    final distance = const Distance();
    final normalizedQuery = query.trim().toLowerCase();

    final items = _stores
        .where((store) {
          final matchesCategory = category == StoreCategory.all || store.category == category;
          final searchableText = '${store.name} ${store.category.label} ${store.address}'.toLowerCase();
          final matchesQuery = normalizedQuery.isEmpty || searchableText.contains(normalizedQuery);
          return matchesCategory && matchesQuery;
        })
        .map(
          (store) => StoreWithDistance(
            store: store,
            distanceMeters: distance(userLocation, store.position),
          ),
        )
        .toList();

    items.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return items;
  }
}
