import 'package:flutter/material.dart';

import '../../../../shared/models/store_category.dart';

class CategoryFilters extends StatelessWidget {
  const CategoryFilters({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final StoreCategory selectedCategory;
  final ValueChanged<StoreCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StoreCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selectedCategory == category,
              avatar: Icon(category.icon, size: 18),
              label: Text(category.label),
              onSelected: (_) => onSelected(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}
