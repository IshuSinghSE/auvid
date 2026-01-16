import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SettingsProvider extends ChangeNotifier {
  static const String _keyDownloadPath = 'download_path';
  static const String _keyDefaultQuality = 'default_quality';
  static const String _keyDefaultAudioFormat = 'default_audio_format';
  static const String _keyDefaultVideoFormat = 'default_video_format';
  static const String _keyThemeMode = 'theme_mode';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Settings values
  String _downloadPath = '';
  String _defaultQuality = 'Best available';
  String _defaultAudioFormat = 'mp3';
  String _defaultVideoFormat = 'mp4';
  String _themeMode = 'system'; // 'light', 'dark', or 'system'

  // Getters
  bool get isInitialized => _isInitialized;
  String get downloadPath => _downloadPath;
  String get defaultQuality => _defaultQuality;
  String get defaultAudioFormat => _defaultAudioFormat;
  String get defaultVideoFormat => _defaultVideoFormat;
  String get themeMode => _themeMode;
  
  // Theme mode options
  List<String> get themeModeOptions => ['System', 'Light', 'Dark'];
  
  // Legacy getter for backward compatibility
  bool get darkMode => _themeMode == 'dark';

  // Quality options
  List<String> get qualityOptions => [
    'Best available',
    '2160p (4K)',
    '1440p (2K)',
    '1080p (Full HD)',
    '720p (HD)',
    '480p',
    '360p',
  ];

  // Audio format options
  List<String> get audioFormatOptions => [
    'mp3',
    'm4a',
    'opus',
    'wav',
    'flac',
  ];

  // Video format options
  List<String> get videoFormatOptions => [
    'mp4',
    'mkv',
    'webm',
    'mov',
    'flv',
  ];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load saved settings or use defaults
    _downloadPath = _prefs.getString(_keyDownloadPath) ?? await _getDefaultDownloadPath();
    _defaultQuality = _prefs.getString(_keyDefaultQuality) ?? 'Best available';
    _defaultAudioFormat = _prefs.getString(_keyDefaultAudioFormat) ?? 'mp3';
    _defaultVideoFormat = _prefs.getString(_keyDefaultVideoFormat) ?? 'mp4';
    _themeMode = _prefs.getString(_keyThemeMode) ?? 'system';
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<String> _getDefaultDownloadPath() async {
    if (Platform.isLinux || Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/Downloads';
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      return '$userProfile\\Downloads';
    }
    return '';
  }

  Future<void> setDownloadPath(String path) async {
    _downloadPath = path;
    await _prefs.setString(_keyDownloadPath, path);
    notifyListeners();
  }

  Future<void> setDefaultQuality(String quality) async {
    _defaultQuality = quality;
    await _prefs.setString(_keyDefaultQuality, quality);
    notifyListeners();
  }

  Future<void> setDefaultAudioFormat(String format) async {
    _defaultAudioFormat = format;
    await _prefs.setString(_keyDefaultAudioFormat, format);
    notifyListeners();
  }

  Future<void> setDefaultVideoFormat(String format) async {
    _defaultVideoFormat = format;
    await _prefs.setString(_keyDefaultVideoFormat, format);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode.toLowerCase();
    await _prefs.setString(_keyThemeMode, _themeMode);
    notifyListeners();
  }

  // Legacy method for backward compatibility
  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? 'dark' : 'light';
    await _prefs.setString(_keyThemeMode, _themeMode);
    notifyListeners();
  }

  String getDisplayPath() {
    if (_downloadPath.isEmpty) return '~/Downloads';
    
    // Shorten path for display
    if (Platform.isLinux || Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '';
      if (_downloadPath.startsWith(home)) {
        return _downloadPath.replaceFirst(home, '~');
      }
    }
    
    return _downloadPath;
  }
}
