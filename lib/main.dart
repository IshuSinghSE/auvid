import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auvid/core/theme.dart';
import 'package:auvid/ui/screens/home_screen.dart';
import 'package:auvid/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();
  runApp(VideoDownloaderApp(settingsProvider: settingsProvider));
}

class VideoDownloaderApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  
  const VideoDownloaderApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settingsProvider,
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'auvid',
            debugShowCheckedModeBanner: false,
            theme: settings.darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
