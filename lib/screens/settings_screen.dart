import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _adminEmailController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _offlineModeEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _adminEmailController.dispose();
    super.dispose();
  }

  /// Load current settings
  void _loadSettings() {
    final appState = context.read<AppState>();
    _adminEmailController.text = appState.adminEmail ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Admin Email Section
          _buildSection(
            title: 'Admin Email',
            children: [
              TextField(
                controller: _adminEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Admin Email',
                  hintText: 'admin@company.com',
                  border: OutlineInputBorder(),
                  helperText: 'Email address for discrepancy notifications',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive push notifications for important events'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Offline Mode Section
          _buildSection(
            title: 'Offline Mode',
            children: [
              SwitchListTile(
                title: const Text('Enable Offline Mode'),
                subtitle: const Text('Queue data when offline and sync when online'),
                value: _offlineModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _offlineModeEnabled = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Data Management Section
          _buildSection(
            title: 'Data Management',
            children: [
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync Offline Data'),
                subtitle: const Text('Upload queued data to Google Sheets'),
                onTap: _syncOfflineData,
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('Clear All Data'),
                subtitle: const Text('Remove all containers and offline data'),
                onTap: _showClearDataDialog,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // App Information Section
          _buildSection(
            title: 'App Information',
            children: [
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('About'),
                subtitle: const Text('Warehouse Container Tracker'),
                onTap: _showAboutDialog,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Google Sheets Configuration Section
          _buildSection(
            title: 'Google Sheets Configuration',
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Spreadsheet ID'),
                subtitle: const Text('Configure your Google Sheets ID'),
                onTap: _showSpreadsheetConfigDialog,
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Service Account'),
                subtitle: const Text('Configure service account credentials'),
                onTap: _showServiceAccountDialog,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Firebase Configuration Section
          _buildSection(
            title: 'Firebase Configuration',
            children: [
              ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('Storage Bucket'),
                subtitle: const Text('Configure Firebase Storage bucket'),
                onTap: _showFirebaseConfigDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build section widget
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Save settings
  void _saveSettings() {
    final adminEmail = _adminEmailController.text.trim();
    
    if (adminEmail.isNotEmpty && !_isValidEmail(adminEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AppState>().setAdminEmail(adminEmail);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Sync offline data
  void _syncOfflineData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Offline Data'),
        content: const Text('This will upload all queued data to Google Sheets. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Show loading indicator
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                await context.read<AppState>().syncOfflineQueue();
                if (mounted) {
                  navigator.pop(); // Close loading dialog
                  
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Offline data synced successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  navigator.pop(); // Close loading dialog
                  
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to sync data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Sync'),
          ),
        ],
      ),
    );
  }

  /// Show clear data dialog
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all containers and offline data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppState>().clearAllData();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Warehouse Container Tracker',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Warehouse Solutions',
      children: [
        const Text(
          'A Flutter app for tracking warehouse container unloading/loading with Google Sheets integration.',
        ),
      ],
    );
  }

  /// Show spreadsheet configuration dialog
  void _showSpreadsheetConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Sheets Configuration'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To configure Google Sheets:'),
            SizedBox(height: 8),
            Text('1. Create a Google Sheet'),
            Text('2. Set up columns: Container #, Type, Status, etc.'),
            Text('3. Create a service account'),
            Text('4. Share the sheet with the service account'),
            Text('5. Add the spreadsheet ID to your configuration'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show service account configuration dialog
  void _showServiceAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Account Configuration'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To configure service account:'),
            SizedBox(height: 8),
            Text('1. Go to Google Cloud Console'),
            Text('2. Create a new service account'),
            Text('3. Download the JSON key file'),
            Text('4. Add the credentials to your app'),
            Text('5. Set GOOGLE_SERVICE_ACCOUNT_JSON environment variable'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show Firebase configuration dialog
  void _showFirebaseConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Configuration'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To configure Firebase:'),
            SizedBox(height: 8),
            Text('1. Create a Firebase project'),
            Text('2. Enable Storage and Cloud Messaging'),
            Text('3. Add iOS/Android apps to the project'),
            Text('4. Download configuration files'),
            Text('5. Add google-services.json/GoogleService-Info.plist'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
