import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class ContriApp extends StatelessWidget {
  const ContriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contri',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const AppRouter(),
    );
  }
}