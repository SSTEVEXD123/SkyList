import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skylist/storage_manager/app_settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark theme'),
            subtitle: const Text('Toggle between dark and light mode'),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (_) => settings.toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clean cache and history'),
            onTap: () async {
              await settings.clearCacheAndHistory();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache and history removed')),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.verified_outlined),
            title: Text('App version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.system_update_alt_outlined),
            title: const Text('Check for updates'),
            subtitle: const Text('Manual update checker placeholder'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You are on the latest version.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
