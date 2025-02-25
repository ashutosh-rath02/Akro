// lib/features/auth/screens/lock_screen.dart
import 'package:Akro/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_colors.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _isAuthenticating = false;
  bool _isBiometricsAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  String _statusMessage = 'Checking biometrics...';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final isEnabled = await AuthService.isBiometricEnabled();
      debugPrint('Biometric enabled preference: $isEnabled');

      if (!isEnabled) {
        setState(() {
          _statusMessage = 'Biometric authentication is disabled in settings';
        });

        // If biometrics not enabled, go to home and clear history
        if (mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            AppRouter.navigateToHomeAndClear();
          });
        }
        return;
      }

      final isAvailable = await AuthService.isBiometricsAvailable();
      final availableBiometrics = await AuthService.getAvailableBiometrics();

      debugPrint('Biometrics available: $isAvailable');
      debugPrint('Available biometrics: $availableBiometrics');

      if (mounted) {
        setState(() {
          _isBiometricsAvailable = isAvailable;
          _availableBiometrics = availableBiometrics;
          _statusMessage =
              isAvailable
                  ? 'Biometrics available: ${availableBiometrics.join(', ')}'
                  : 'Biometrics not available on this device';
        });
      }

      if (isAvailable) {
        // Small delay to allow the screen to render before showing the auth prompt
        await Future.delayed(const Duration(milliseconds: 500));
        _authenticate();
      } else {
        // If biometrics not available, go to home and clear history
        if (mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            AppRouter.navigateToHomeAndClear();
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
      setState(() {
        _statusMessage = 'Error checking biometrics: $e';
      });

      // On error, still go to home screen after showing message
      if (mounted) {
        Future.delayed(const Duration(seconds: 3), () {
          AppRouter.navigateToHomeAndClear();
        });
      }
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Authenticating...';
    });

    try {
      final authenticated = await AuthService.authenticate(
        reason: 'Authenticate to access your checklists',
        context: context,
      );

      debugPrint('Authentication result: $authenticated');

      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _statusMessage =
              authenticated
                  ? 'Authentication successful!'
                  : 'Authentication failed. Try again.';
        });

        if (authenticated) {
          // Small delay to show success message
          await Future.delayed(const Duration(milliseconds: 500));
          AppRouter.navigateToHomeAndClear();
        }
      }
    } catch (e) {
      debugPrint('Error during authentication: $e');
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _statusMessage = 'Authentication error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Akro',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Secure your daily checks with biometric authentication',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _statusMessage.contains('Error') ||
                                _statusMessage.contains('failed')
                            ? AppColors.error
                            : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                if (_isBiometricsAvailable)
                  ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : () => _authenticate(),
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Authenticate'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                if (!_isBiometricsAvailable)
                  ElevatedButton(
                    onPressed: () {
                      AppRouter.navigateToHomeAndClear();
                    },
                    child: const Text('Continue Without Biometrics'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    AppRouter.navigateToHomeAndClear();
                  },
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
