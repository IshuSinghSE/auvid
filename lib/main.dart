import 'package:flutter/material.dart';
import 'package:video_downloader_reborn/core/theme.dart';
import 'package:video_downloader_reborn/ui/screens/home_screen.dart';

void main() {
  runApp(const VideoDownloaderApp());
}

class VideoDownloaderApp extends StatelessWidget {
  const VideoDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Downloader Reborn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // <--- Applying your custom theme
      home: const HomeScreen(),
    );
  }
}
