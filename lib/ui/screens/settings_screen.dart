import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants.dart';
import '../../providers/settings_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
            title: const Text('Settings'),
          ),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingLarge,
                  horizontal: AppConstants.spacingXLarge,
                ),
                children: [
                  const SizedBox(height: AppConstants.spacingMedium),
                  _buildSectionHeader(context, 'General'),
                  const SizedBox(height: AppConstants.spacingSmall),
                  _buildSettingsTile(
                    context,
                    icon: Icons.folder_outlined,
                    title: 'Download Location',
                    subtitle: settings.getDisplayPath(),
                    onTap: () => _selectDownloadFolder(context, settings),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.high_quality,
                    title: 'Default Quality',
                    subtitle: settings.defaultQuality,
                    onTap: () => _showQualityPicker(context, settings),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.audio_file_outlined,
                    title: 'Default Audio Format',
                    subtitle: settings.defaultAudioFormat.toUpperCase(),
                    onTap: () => _showAudioFormatPicker(context, settings),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const Divider(height: 1),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildSectionHeader(context, 'Appearance'),
                  const SizedBox(height: AppConstants.spacingSmall),
                  _buildSwitchTile(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Always use dark theme',
                    value: settings.darkMode,
                    onChanged: (value) => settings.setDarkMode(value),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const Divider(height: 1),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildSectionHeader(context, 'About'),
                  const SizedBox(height: AppConstants.spacingSmall),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Version, credits, and more',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                  // _buildSettingsTile(
                  //   context,
                  //   icon: Icons.code,
                  //   title: 'Open Source Licenses',
                  //   subtitle: 'View licenses',
                  //   onTap: () {
                  //     showLicensePage(
                  //       context: context,
                  //       applicationName: 'auvid',
                  //       applicationVersion: '1.0.0',
                  //       applicationIcon: Image.asset(
                  //         'assets/images/logo.png',
                  //         width: 48,
                  //         height: 48,
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: AppConstants.spacingXLarge),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDownloadFolder(BuildContext context, SettingsProvider settings) async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Download Folder',
        initialDirectory: settings.downloadPath.isEmpty ? null : settings.downloadPath,
      );

      if (result != null) {
        await settings.setDownloadPath(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download location updated: ${settings.getDisplayPath()}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting folder: \$e')),
        );
      }
    }
  }

  Future<void> _showQualityPicker(BuildContext context, SettingsProvider settings) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: settings.qualityOptions.map((quality) {
            return RadioListTile<String>(
              title: Text(quality),
              value: quality,
              groupValue: settings.defaultQuality,
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null) {
      await settings.setDefaultQuality(selected);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Default quality set to: $selected')),
        );
      }
    }
  }

  Future<void> _showAudioFormatPicker(BuildContext context, SettingsProvider settings) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Audio Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: settings.audioFormatOptions.map((format) {
            return RadioListTile<String>(
              title: Text(format.toUpperCase()),
              subtitle: Text(_getFormatDescription(format)),
              value: format,
              groupValue: settings.defaultAudioFormat,
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null) {
      await settings.setDefaultAudioFormat(selected);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Default audio format set to: \${selected.toUpperCase()}')),
        );
      }
    }
  }

  String _getFormatDescription(String format) {
    switch (format) {
      case 'mp3':
        return 'Universal compatibility';
      case 'm4a':
        return 'Better quality, Apple devices';
      case 'opus':
        return 'Best quality/size ratio';
      case 'wav':
        return 'Lossless, large files';
      case 'flac':
        return 'Lossless compression';
      default:
        return '';
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
        vertical: AppConstants.spacingSmall,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
