import 'package:flutter/material.dart';

/// Settings menu item widget
class SettingsMenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsMenuItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}
