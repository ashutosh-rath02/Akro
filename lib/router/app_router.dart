// lib/core/router/app_router.dart
import 'package:Akro/features/checklist/screens/lock_screen.dart';
import 'package:Akro/features/checklist/screens/settiings_screen.dart';
import 'package:flutter/material.dart';
import '../../features/checklist/models/checklist_template.dart';
import '../../features/checklist/screens/add_template_screen.dart';
import '../../features/checklist/screens/home_screen.dart';
import '../../features/checklist/screens/template_checks_screen.dart';

class AppRouter {
  // Add a navigator key for global navigation
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Navigate to home and clear history
  static void navigateToHomeAndClear() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/lock':
        return MaterialPageRoute(builder: (_) => const LockScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/checklist':
        final template = settings.arguments as ChecklistTemplate;
        return MaterialPageRoute(
          builder: (_) => TemplateChecksScreen(template: template),
        );
      case '/add-template':
        return MaterialPageRoute(builder: (_) => const AddTemplateScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text('Route not found!'))),
        );
    }
  }
}
