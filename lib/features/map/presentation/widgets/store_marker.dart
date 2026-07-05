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
