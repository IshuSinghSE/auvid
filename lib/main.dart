import 'package:flutter/material.dart';
import 'package:auvid/core/theme.dart';
import 'package:auvid/ui/screens/home_screen.dart';

void main() {
  runApp(const VideoDownloaderApp());
}

class VideoDownloaderApp extends StatelessWidget {
  const VideoDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'auvid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // <--- Applying your custom theme
      home: const HomeScreen(),
    );
  }
}
