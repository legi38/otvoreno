import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 250,
      child: FloatingActionButton(
        onPressed: onPressed,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
