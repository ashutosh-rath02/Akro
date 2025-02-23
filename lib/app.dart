import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'router/app_router.dart';

class HomeSecurityApp extends StatelessWidget {
  const HomeSecurityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Security Checklist',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
