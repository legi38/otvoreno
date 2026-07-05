import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('Postavke', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          const ListTile(leading: Icon(Icons.language), title: Text('Jezik'), subtitle: Text('Hrvatski')),
          const ListTile(leading: Icon(Icons.dark_mode_outlined), title: Text('Tema'), subtitle: Text('Prema sustavu')),
          const ListTile(leading: Icon(Icons.verified_outlined), title: Text('Pouzdanost podataka'), subtitle: Text('Korisnici mogu prijaviti netočno radno vrijeme')),
        ],
      ),
    );
  }
}
