import 'package:flutter/material.dart';
import '../services/mock_store_service.dart';
import '../widgets/store_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stores = MockStoreService.nearbyStores();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green),
              const SizedBox(width: 8),
              Text('Otvoreno?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pronađi što je otvoreno u blizini', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Trgovine, ljekarne, pekare i benzinske postaje.', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green.shade700),
                  onPressed: () {},
                  icon: const Icon(Icons.my_location),
                  label: const Text('Koristi moju lokaciju'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('U blizini', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final store in stores) StoreCard(store: store),
        ],
      ),
    );
  }
}
