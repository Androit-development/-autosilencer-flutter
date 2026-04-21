import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/driver_mode_viewmodel.dart';
import '../theme/index.dart';

/// Settings screen for managing driver mode app freezing
class AppFreezeSettingsScreen extends StatefulWidget {
  const AppFreezeSettingsScreen({super.key});

  @override
  State<AppFreezeSettingsScreen> createState() => _AppFreezeSettingsScreenState();
}

class _AppFreezeSettingsScreenState extends State<AppFreezeSettingsScreen> {
  static const _deviceAdminChannel = MethodChannel('autosilencer/device_admin');
  bool _isDeviceAdminEnabled = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDeviceAdminStatus();
  }

  Future<void> _checkDeviceAdminStatus() async {
    try {
      final result = await _deviceAdminChannel.invokeMethod<bool>('isDeviceAdminEnabled');
      setState(() {
        _isDeviceAdminEnabled = result ?? false;
        _isChecking = false;
      });
    } catch (e) {
      debugPrint('❌ Error checking device admin status: $e');
      setState(() => _isChecking = false);
    }
  }

  Future<void> _requestDeviceAdminAccess() async {
    try {
      await _deviceAdminChannel.invokeMethod('requestDeviceAdminAccess');
      // Delay check to allow user to enable it
      await Future.delayed(const Duration(milliseconds: 500));
      await _checkDeviceAdminStatus();
    } catch (e) {
      debugPrint('❌ Error requesting device admin: $e');
      _showSnack('Failed to request device admin access', isError: true);
    }
  }

  Future<void> _unfreezeAllApps() async {
    try {
      debugPrint('🔥 User requesting to unfreeze all apps');
      await _deviceAdminChannel.invokeMethod('unfreezeAllApps');
      _showSnack('All apps unfrozen', isError: false);
      
      // Also disable driver mode
      final driverVM = context.read<DriverModeViewModel>();
      await driverVM.toggleDriverMode();
    } catch (e) {
      debugPrint('❌ Error unfreezing apps: $e');
      _showSnack('Failed to unfreeze apps', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Freeze Settings'),
        backgroundColor: const Color(0xFF2979FF),
        elevation: 0,
      ),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device Admin Status Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isDeviceAdminEnabled
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _isDeviceAdminEnabled
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: _isDeviceAdminEnabled
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Device Admin Status',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isDeviceAdminEnabled
                                          ? 'Device admin is enabled'
                                          : 'Device admin is not enabled',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!_isDeviceAdminEnabled) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _requestDeviceAdminAccess,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2979FF),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Enable Device Admin',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Freezing Info
                  const Text(
                    'About App Freezing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'When Driver Mode is active, selected apps will be frozen to prevent distraction while driving. Only Whitelisted apps (Phone, Maps) will remain accessible.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Frozen Apps List
                  const Text(
                    'Frozen Apps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<DriverModeViewModel>(
                    builder: (context, driverVM, _) {
                      final frozenApps = driverVM.allApps
                          .where((app) => !app.isEnabled && app.category != 'Essential')
                          .toList();

                      if (frozenApps.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No apps will be frozen',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: frozenApps.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final app = frozenApps[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Text(
                                app.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Text(app.name),
                              subtitle: Text(app.category),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '❄️ Frozen',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Unfreeze Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _unfreezeAllApps,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.lock_open),
                      label: const Text(
                        'Unfreeze All Apps & Exit Driver Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Warning
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Only use this settings page to unfreeze apps. Closing this app will NOT unfreeze them.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
