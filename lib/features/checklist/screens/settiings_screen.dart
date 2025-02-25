// lib/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;
  bool _biometricsAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final biometricsAvailable = await AuthService.isBiometricsAvailable();
    final biometricEnabled = await AuthService.isBiometricEnabled();

    if (mounted) {
      setState(() {
        _biometricsAvailable = biometricsAvailable;
        _biometricEnabled = biometricEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_biometricsAvailable) return;

    setState(() {
      _isLoading = true;
    });

    // If enabling, check if authentication works
    if (value) {
      final authenticated = await AuthService.authenticate(
        reason: 'Authenticate to enable biometric lock',
        context: context,
      );

      if (!authenticated) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    await AuthService.setBiometricEnabled(value);

    if (mounted) {
      setState(() {
        _biometricEnabled = value;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Biometric authentication enabled'
                : 'Biometric authentication disabled',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Security',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Biometric Authentication'),
                            subtitle: const Text(
                              'Lock the app with fingerprint or face ID',
                            ),
                            value: _biometricEnabled,
                            onChanged:
                                _biometricsAvailable
                                    ? (value) => _toggleBiometric(value)
                                    : null,
                            activeColor: AppColors.primary,
                          ),
                          if (!_biometricsAvailable)
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 8,
                              ),
                              child: Text(
                                'Biometric authentication is not available on this device',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Management',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: const Text('Clear All Data'),
                            subtitle: const Text(
                              'Delete all templates and checks',
                            ),
                            trailing: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                            onTap: () => _showClearDataDialog(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: const Text('Version'),
                            subtitle: const Text('1.0.0'),
                            trailing: const Icon(Icons.info_outline),
                            onTap: () {
                              showAboutDialog(
                                context: context,
                                applicationName: 'Akro',
                                applicationVersion: '1.0.0',
                                applicationIcon: const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.primary,
                                  size: 50,
                                ),
                                applicationLegalese: '© 2025 Akro',
                              );
                            },
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Help & Support'),
                            subtitle: const Text(
                              'Get assistance with using the app',
                            ),
                            trailing: const Icon(Icons.help_outline),
                            onTap: () {
                              // Show help dialog
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Help & Support'),
                                      content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Need help with Akro?'),
                                          SizedBox(height: 16),
                                          Text(
                                            '• Create templates for regular checks',
                                          ),
                                          Text(
                                            '• Take photos for verification',
                                          ),
                                          Text(
                                            '• Track your completion progress',
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'For more information, visit our website.',
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'This will permanently delete all your templates and checks. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement data clearing functionality
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
