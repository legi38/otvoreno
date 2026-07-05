import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

class OtvorenoApp extends StatelessWidget {
  const OtvorenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otvoreno',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}
