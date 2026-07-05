import 'package:flutter/material.dart';

import '../../../../shared/models/store_place.dart';
import '../../../../shared/models/store_with_distance.dart';
import 'store_card.dart';

class MapBottomSheet extends StatelessWidget {
  const MapBottomSheet({
    super.key,
    required this.loading,
    required this.error,
    required this.visibleStores,
    required this.selectedStore,
    required this.onStoreTap,
  });

  final bool loading;
  final String? error;
  final List<StoreWithDistance> visibleStores;
  final StorePlace? selectedStore;
  final ValueChanged<StorePlace> onStoreTap;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.31,
      minChildSize: 0.18,
      maxChildSize: 0.72,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [BoxShadow(blurRadius: 22, color: Colors.black26)],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Mjesta u blizini',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text('${visibleStores.length}'),
                ],
              ),
              const SizedBox(height: 6),
              if (loading)
                const Text('Tražim tvoju lokaciju...')
              else if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red))
              else
                const Text('Sprint 4: kod je sada razdvojen u čistu arhitekturu.'),
              const SizedBox(height: 14),
              if (visibleStores.isEmpty)
                const _EmptyState()
              else
                ...visibleStores.map(
                  (item) => StoreCard(
                    item: item,
                    selected: selectedStore?.id == item.store.id,
                    onTap: () => onStoreTap(item.store),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(child: Text('Nema rezultata za odabrani filter.')),
    );
  }
}
