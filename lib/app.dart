import 'package:Akro/router/app_router.dart';
import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';

class AkroApp extends StatelessWidget {
  const AkroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
