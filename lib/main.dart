// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/objectbox_store.dart';
import 'core/services/auth_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ObjectBox
  objectBox = await ObjectBox.create();

  await AuthService.setBiometricEnabled(true);

  final biometricEnabled = await AuthService.isBiometricEnabled();
  print('Biometric authentication enabled: $biometricEnabled');

  // Check if biometrics are available
  final biometricsAvailable = await AuthService.isBiometricsAvailable();
  print('Biometrics available: $biometricsAvailable');

  runApp(
    ProviderScope(
      child: AkroApp(startWithLock: biometricEnabled && biometricsAvailable),
    ),
  );
}
