import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/objectbox_store.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ObjectBox
  objectBox = await ObjectBox.create();

  runApp(const ProviderScope(child: AkroApp()));
}
