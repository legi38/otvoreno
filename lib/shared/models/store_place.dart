import 'package:latlong2/latlong.dart';

import 'store_category.dart';

enum StoreOpenStatus { open, closed, unknown }

class StorePlace {
  const StorePlace({
    required this.id,
    required this.name,
    required this.position,
    required this.category,
    required this.address,
    this.openStatus = StoreOpenStatus.unknown,
    this.openUntil,
    this.openingHours,
    this.source = 'OpenStreetMap',
  });

  final String id;
  final String name;
  final LatLng position;
  final StoreCategory category;
  final StoreOpenStatus openStatus;
  final String? openUntil;
  final String? openingHours;
  final String address;
  final String source;

  bool get isOpen => openStatus == StoreOpenStatus.open;
}
