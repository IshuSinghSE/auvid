import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme.dart';
import '../../providers/settings_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Settings",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // GENERAL SECTION
                  _buildSectionHeader("GENERAL"),
                  _buildSettingsCard(
                    children: [
                      _buildTile(
                        icon: Icons.folder_open_rounded,
                        title: "Download Location",
                        subtitle: settings.getDisplayPath(),
                        onTap: () => _selectDownloadFolder(context, settings),
                      ),
                      _buildDivider(),
                      _buildDropdownTile(
                        icon: Icons.hd_outlined,
                        title: "Default Quality",
                        value: settings.defaultQuality,
                        items: settings.qualityOptions,
                        onChanged: (val) {
                          if (val != null) settings.setDefaultQuality(val);
                        },
                      ),
                      _buildDivider(),
                      _buildDropdownTile(
                        icon: Icons.audio_file_outlined,
                        title: "Default Audio Format",
                        value: settings.defaultAudioFormat.toUpperCase(),
                        items: settings.audioFormatOptions.map((e) => e.toUpperCase()).toList(),
                        onChanged: (val) {
                          if (val != null) settings.setDefaultAudioFormat(val.toLowerCase());
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // APPEARANCE SECTION
                  _buildSectionHeader("APPEARANCE"),
                  _buildSettingsCard(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: "Dark Mode",
                        subtitle: "Uses the Auvid minimal theme",
                        value: settings.darkMode,
                        onChanged: (val) => settings.setDarkMode(val),
                      ),
                      _buildDivider(),
                      _buildTile(
                        icon: Icons.palette_outlined,
                        title: "Accent Color",
                        subtitle: "Auvid Purple",
                        trailing: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // SYSTEM & ABOUT
                  _buildSectionHeader("SYSTEM"),
                  _buildSettingsCard(
                    children: [
                      _buildTile(
                        icon: Icons.terminal_rounded,
                        title: "Engine Version",
                        subtitle: "yt-dlp (bundled)",
                        trailing: const Text(
                          "Stable",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      _buildDivider(),
                      _buildTile(
                        icon: Icons.info_outline_rounded,
                        title: "About Auvid",
                        subtitle: "v1.0.0 • Built with Flutter",
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AboutScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      activeColor: AppTheme.primary,
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: value ? AppTheme.primary : Colors.grey, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: AppTheme.surface,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 60,
      endIndent: 20,
    );
  }

  // --- SETTINGS LOGIC ---

  Future<void> _selectDownloadFolder(
    BuildContext context,
    SettingsProvider settings,
  ) async {
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
          SnackBar(content: Text('Error selecting folder: $e')),
        );
      }
    }
  }
}
