import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final _auth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Check if biometrics are available on the device
  static Future<bool> isBiometricsAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      debugPrint('canCheckBiometrics: $canAuthenticateWithBiometrics');

      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      debugPrint('canAuthenticate: $canAuthenticate');

      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: ${e.message}, code: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error checking biometrics: $e');
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      debugPrint('Available biometrics: $biometrics');
      return biometrics;
    } on PlatformException catch (e) {
      debugPrint(
        'Error getting available biometrics: ${e.message}, code: ${e.code}',
      );
      return [];
    } catch (e) {
      debugPrint('Unexpected error getting biometrics: $e');
      return [];
    }
  }

  // Authenticate with biometrics
  static Future<bool> authenticate({
    required String reason,
    required BuildContext context,
  }) async {
    try {
      debugPrint('Starting authentication...');

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      debugPrint('Authentication result: $authenticated');
      return authenticated;
    } on PlatformException catch (e) {
      debugPrint('Error authenticating: ${e.message}, code: ${e.code}');

      if (e.code == 'NotAvailable') {
        // Biometrics not available
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication not available'),
            ),
          );
        }
      } else if (e.code == 'NotEnrolled') {
        // No biometrics enrolled
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No biometric authentication enrolled on this device',
              ),
            ),
          );
        }
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Too many failed attempts. Please try again later.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      return false;
    } catch (e) {
      debugPrint('Unexpected error during authentication: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Authentication error: $e')));
      }
      return false;
    }
  }

  // Save biometric preference
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, enabled);
      debugPrint('Biometric enabled set to: $enabled');
    } catch (e) {
      debugPrint('Error saving biometric preference: $e');
    }
  }

  // Get biometric preference
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_biometricEnabledKey) ?? false;
      debugPrint('Biometric enabled preference: $enabled');
      return enabled;
    } catch (e) {
      debugPrint('Error getting biometric preference: $e');
      return false;
    }
  }
}
