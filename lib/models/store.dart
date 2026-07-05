enum StoreCategory { grocery, pharmacy, bakery, gasStation, cafe, restaurant }

class Store {
  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceMeters,
    required this.isOpen,
    required this.statusText,
    required this.category,
    this.rating,
    this.phone,
  });

  final String id;
  final String name;
  final String address;
  final int distanceMeters;
  final bool isOpen;
  final String statusText;
  final StoreCategory category;
  final double? rating;
  final String? phone;

  String get distanceLabel {
    if (distanceMeters < 1000) return '$distanceMeters m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }
}
