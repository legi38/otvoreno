import 'store_place.dart';

class StoreWithDistance {
  const StoreWithDistance({
    required this.store,
    required this.distanceMeters,
  });

  final StorePlace store;
  final double distanceMeters;
}
