import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/objectbox_store.dart';
import 'app.dart';

// Make main async
void main() async {
  // This is needed to ensure platform channels are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ObjectBox and wait for it
  objectBox = await ObjectBox.create();

  runApp(const ProviderScope(child: HomeSecurityApp()));
}
