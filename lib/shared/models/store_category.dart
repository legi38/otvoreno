import 'package:flutter/material.dart';

enum StoreCategory {
  all('Sve', Icons.apps),
  shops('Trgovine', Icons.shopping_cart),
  pharmacies('Ljekarne', Icons.local_hospital),
  gas('Benzinske', Icons.local_gas_station),
  bakeries('Pekare', Icons.bakery_dining);

  const StoreCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}
