import 'package:latlong2/latlong.dart';

import 'store_category.dart';

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
