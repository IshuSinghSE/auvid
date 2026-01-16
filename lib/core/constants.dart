/// Application-wide constants

import 'package:flutter/material.dart';

class AppConstants {
  // Dimensions
  static const double maxContentWidth = 1000.0;
  static const double inputScreenWidth = 600.0;
  static const double thumbnailHeight = 240.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 56.0;
  
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;
  
  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration progressUpdateDuration = Duration(milliseconds: 100);
  
  // Breakpoints
  static const double wideLayoutBreakpoint = 800.0;
  
  // Download settings
  static const String defaultAudioFormat = 'mp3';
  static const String defaultQuality = '720';
  
  // Text
  static const String appTitle = 'Downloader.';
  static const String appSubtitle = 'Paste a link. Get the file. Simple.';
  static const String urlHint = 'https://youtube.com/watch?v=...';
  
  // Error messages
  static const String errorEmptyUrl = 'Please enter a URL';
  static const String errorSelectFormat = 'Please select a format';
  static const String errorFetchInfo = 'Could not fetch video info';
  
  // Status messages
  static const String statusFetching = 'Fetching video information...';
  static const String statusDownloading = 'Starting download...';
  static const String statusComplete = 'Download finished';
  static const String statusCancelled = 'Download cancelled';
}

class AppStyles {
  // Text styles
  static const TextStyle titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: -1.5,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  // Border radius
  static BorderRadius borderRadiusSmall = BorderRadius.circular(8.0);
  static BorderRadius borderRadiusMedium = BorderRadius.circular(12.0);
  static BorderRadius borderRadiusLarge = BorderRadius.circular(16.0);
  
  // Shadows
  static List<BoxShadow> cardShadow(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> glowEffect(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
