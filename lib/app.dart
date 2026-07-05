import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/map/presentation/map_home_screen.dart';

class OtvorenoApp extends StatelessWidget {
  const OtvorenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otvoreno',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const MapHomeScreen(),
    );
  }
}
