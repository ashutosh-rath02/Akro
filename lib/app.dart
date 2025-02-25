import 'package:Akro/router/app_router.dart';
import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';

class AkroApp extends StatelessWidget {
  final bool startWithLock;

  const AkroApp({super.key, this.startWithLock = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: startWithLock ? '/lock' : '/',
      navigatorKey:
          AppRouter.navigatorKey, // Add a navigator key for global navigation
    );
  }
}
