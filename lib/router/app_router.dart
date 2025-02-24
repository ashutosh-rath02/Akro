import 'package:Akro/features/checklist/screens/add_template_screen.dart';
import 'package:Akro/features/checklist/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../../features/checklist/screens/template_checks_screen.dart';
import '../../features/checklist/models/checklist_template.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
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
