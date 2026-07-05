import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/models/store_place.dart';
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

  Color _statusColor(StorePlace store) {
    switch (store.openStatus) {
      case StoreOpenStatus.open:
        return Colors.green;
      case StoreOpenStatus.closed:
        return Colors.red;
      case StoreOpenStatus.unknown:
        return Colors.orange;
    }
  }

  String _statusText(StorePlace store) {
    if (store.statusLabel != null && store.statusLabel!.isNotEmpty) {
      return store.statusLabel!;
    }

    switch (store.openStatus) {
      case StoreOpenStatus.open:
        return store.openUntil == null ? 'Otvoreno' : 'Otvoreno · ${store.openUntil}';
      case StoreOpenStatus.closed:
        return store.openUntil == null ? 'Zatvoreno' : 'Zatvoreno · otvara u ${store.openUntil}';
      case StoreOpenStatus.unknown:
        return store.openingHours == null
            ? 'Radno vrijeme nije potvrđeno'
            : 'OSM: ${store.openingHours}';
    }
  }

  Future<void> _openNavigation() async {
    final store = item.store;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${store.position.latitude},${store.position.longitude}&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = item.store;
    final statusColor = _statusColor(store);

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
                      _statusText(store),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (store.timeHint != null && store.openStatus == StoreOpenStatus.open) ...[
                      const SizedBox(height: 2),
                      Text(
                        store.timeHint!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      store.confidenceLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Navigacija',
                onPressed: _openNavigation,
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
