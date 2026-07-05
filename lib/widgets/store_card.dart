import 'package:flutter/material.dart';
import '../models/store.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, this.onTap});

  final Store store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = store.isOpen ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(_iconFor(store.category), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(store.distanceLabel, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 15, color: color),
                        const SizedBox(width: 4),
                        Expanded(child: Text(store.statusText, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.navigation_rounded),
                tooltip: 'Navigacija',
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(StoreCategory category) {
    switch (category) {
      case StoreCategory.grocery:
        return Icons.shopping_cart_outlined;
      case StoreCategory.pharmacy:
        return Icons.local_pharmacy_outlined;
      case StoreCategory.bakery:
        return Icons.bakery_dining_outlined;
      case StoreCategory.gasStation:
        return Icons.local_gas_station_outlined;
      case StoreCategory.cafe:
        return Icons.local_cafe_outlined;
      case StoreCategory.restaurant:
        return Icons.restaurant_outlined;
    }
  }
}
