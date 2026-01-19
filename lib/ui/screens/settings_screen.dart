import 'package:flutter/material.dart';
import 'package:path/path.dart';
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                snap: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  "Settings",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // GENERAL SECTION
                          _buildSectionHeader(context, "GENERAL"),
                          _buildSettingsCard(
                            context: context,
                            children: [
                              _buildTile(
                                context: context,
                                icon: Icons.folder_open_rounded,
                                title: "Download Location",
                                subtitle: settings.getDisplayPath(),
                                onTap: () => _selectDownloadFolder(context, settings),
                              ),
                              _buildDivider(context),
                              _buildDropdownTile(
                                context: context,
                                icon: Icons.hd_outlined,
                                title: "Default Quality",
                                value: settings.defaultQuality,
                                items: settings.qualityOptions,
                                onChanged: (val) {
                                  if (val != null) settings.setDefaultQuality(val);
                                },
                              ),
                              _buildDivider(context),
                              _buildDropdownTile(
                                context: context,
                                icon: Icons.movie_outlined,
                                title: "Default Video Format",
                                value: settings.defaultVideoFormat.toUpperCase(),
                                items: settings.videoFormatOptions.map((e) => e.toUpperCase()).toList(),
                                onChanged: (val) {
                                  if (val != null) settings.setDefaultVideoFormat(val.toLowerCase());
                                },
                              ),
                              _buildDivider(context),
                              _buildDropdownTile(
                                context: context,
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
                          _buildSectionHeader(context, "APPEARANCE"),
                          _buildSettingsCard(
                            context: context,
                            children: [
                              _buildDropdownTile(
                                context: context,
                                icon: Icons.brightness_6_outlined,
                                title: "Theme",
                                value: settings.themeMode[0].toUpperCase() + settings.themeMode.substring(1),
                                items: settings.themeModeOptions,
                                onChanged: (val) {
                                  if (val != null) settings.setThemeMode(val);
                                },
                              ),
                              _buildDivider(context),
                              _buildTile(
                                context: context,
                                icon: Icons.palette_outlined,
                                title: "Accent Color",
                                subtitle: "Auvid Purple",
                                trailing: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // SYSTEM & ABOUT
                          _buildSectionHeader(context, "SYSTEM"),
                          _buildSettingsCard(
                            context: context,
                            children: [
                              _buildTile(
                                context: context,
                                icon: Icons.info_outline_rounded,
                                title: "About",
                                subtitle: "v1.0.0",
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: theme.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required BuildContext context, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7), fontSize: 13))
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), size: 18),
    );
  }



  Widget _buildDropdownTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: theme.cardColor,
            icon: Icon(Icons.arrow_drop_down, color: theme.textTheme.bodySmall?.color),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      color: theme.brightness == Brightness.dark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.07),
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
