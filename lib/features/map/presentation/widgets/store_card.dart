import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../shared/models/store_with_distance.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final StoreWithDistance item;
  final bool selected;
  final VoidCallback onTap;

  String _distanceText(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('${_distanceText(item.distanceMeters)} · ${store.address}'),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
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
