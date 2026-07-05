import 'package:flutter/material.dart';

import '../../../../shared/models/store_place.dart';

class StoreMarker extends StatelessWidget {
  const StoreMarker({
    super.key,
    required this.store,
    required this.selected,
  });

  final StorePlace store;
  final bool selected;

  Color _statusColor() {
    switch (store.openStatus) {
      case StoreOpenStatus.open:
        return Colors.green;
      case StoreOpenStatus.closed:
        return Colors.red;
      case StoreOpenStatus.unknown:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

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
