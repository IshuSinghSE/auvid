import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Manages yt-dlp binary lifecycle: download, update, and platform detection
class YtDlpManager {
  static const String _repoOwner = 'yt-dlp';
  static const String _repoName = 'yt-dlp';
  static const String _githubApiUrl = 'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';
  
  String? _binaryPath;
  String? _currentVersion;
  
  /// Initialize the manager and ensure yt-dlp is available
  Future<void> initialize() async {
    final appDir = await _getAppDirectory();
    _binaryPath = path.join(appDir, _getBinaryName());
    
    // Check if binary exists and is executable
    final binaryFile = File(_binaryPath!);
    if (!binaryFile.existsSync()) {
      debugPrint('[YtDlpManager] Binary not found, downloading...');
      await downloadLatest();
    } else {
      // Get current version
      _currentVersion = await _getInstalledVersion();
      debugPrint('[YtDlpManager] Found yt-dlp version: $_currentVersion');
      
      // Ensure executable permissions
      await _ensureExecutablePermissions();
    }
  }
  
  /// Get the path to the yt-dlp binary
  String getBinaryPath() {
    if (_binaryPath == null) {
      throw StateError('YtDlpManager not initialized. Call initialize() first.');
    }
    return _binaryPath!;
  }
  
  /// Download the latest yt-dlp binary for the current platform
  Future<void> downloadLatest() async {
    try {
      debugPrint('[YtDlpManager] Fetching latest release info...');
      
      // Get latest release info from GitHub
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch release info: ${response.statusCode}');
      }
      
      // Parse release data (simple approach without json package)
      final body = response.body;
      final version = _extractVersion(body);
      final downloadUrl = _getDownloadUrl(body);
      
      if (downloadUrl == null) {
        throw Exception('Could not find download URL for current platform');
      }
      
      debugPrint('[YtDlpManager] Downloading yt-dlp $version from: $downloadUrl');
      
      // Download the binary
      final binaryResponse = await http.get(Uri.parse(downloadUrl));
      if (binaryResponse.statusCode != 200) {
        throw Exception('Failed to download binary: ${binaryResponse.statusCode}');
      }
      
      // Save to app directory
      final appDir = await _getAppDirectory();
      _binaryPath = path.join(appDir, _getBinaryName());
      final binaryFile = File(_binaryPath!);
      
      await binaryFile.writeAsBytes(binaryResponse.bodyBytes);
      debugPrint('[YtDlpManager] Binary saved to: $_binaryPath');
      
      // Make executable on Unix systems
      await _ensureExecutablePermissions();
      
      _currentVersion = version;
      debugPrint('[YtDlpManager] Successfully installed yt-dlp $version');
      
    } catch (e) {
      debugPrint('[YtDlpManager] Error downloading yt-dlp: $e');
      rethrow;
    }
  }
  
  /// Check for updates and download if available
  Future<bool> checkAndUpdate() async {
    try {
      debugPrint('[YtDlpManager] Checking for updates...');
      
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode != 200) {
        debugPrint('[YtDlpManager] Failed to check for updates');
        return false;
      }
      
      final latestVersion = _extractVersion(response.body);
      
      _currentVersion ??= await _getInstalledVersion();
      
      if (_currentVersion != latestVersion) {
        debugPrint('[YtDlpManager] Update available: $_currentVersion -> $latestVersion');
        await downloadLatest();
        return true;
      } else {
        debugPrint('[YtDlpManager] Already up to date: $latestVersion');
        return false;
      }
      
    } catch (e) {
      debugPrint('[YtDlpManager] Error checking for updates: $e');
      return false;
    }
  }
  
  /// Get the installed version of yt-dlp
  Future<String?> _getInstalledVersion() async {
    try {
      if (_binaryPath == null || !File(_binaryPath!).existsSync()) {
        return null;
      }
      
      final result = await Process.run(_binaryPath!, ['--version']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      debugPrint('[YtDlpManager] Error getting version: $e');
    }
    return null;
  }
  
  /// Extract version from GitHub API response
  String _extractVersion(String body) {
    // Simple regex to extract version tag
    final match = RegExp(r'"tag_name"\s*:\s*"([^"]+)"').firstMatch(body);
    return match?.group(1) ?? 'unknown';
  }
  
  /// Get the appropriate download URL for the current platform
  String? _getDownloadUrl(String body) {
    final assetName = _getAssetName();
    
    // Find the download URL for this asset
    final pattern = RegExp(
      r'"browser_download_url"\s*:\s*"([^"]*' + RegExp.escape(assetName) + r'[^"]*)"'
    );
    final match = pattern.firstMatch(body);
    
    return match?.group(1);
  }
  
  /// Get the asset name for the current platform
  String _getAssetName() {
    if (Platform.isLinux) {
      return 'yt-dlp_linux';
    } else if (Platform.isMacOS) {
      return 'yt-dlp_macos';
    } else if (Platform.isWindows) {
      return 'yt-dlp.exe';
    } else {
      throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
    }
  }
  
  /// Get the binary name for the current platform
  String _getBinaryName() {
    if (Platform.isWindows) {
      return 'yt-dlp.exe';
    } else {
      return 'yt-dlp';
    }
  }
  
  /// Get the application directory for storing binaries
  Future<String> _getAppDirectory() async {
    // Use application support directory for storing binaries
    final appSupport = await getApplicationSupportDirectory();
    final binDir = Directory(path.join(appSupport.path, 'bin'));
    
    // Create directory if it doesn't exist
    if (!binDir.existsSync()) {
      await binDir.create(recursive: true);
    }
    
    return binDir.path;
  }
  
  /// Ensure the binary has executable permissions (Unix systems)
  Future<void> _ensureExecutablePermissions() async {
    if (!Platform.isWindows && _binaryPath != null) {
      try {
        await Process.run('chmod', ['+x', _binaryPath!]);
        debugPrint('[YtDlpManager] Set executable permissions');
      } catch (e) {
        debugPrint('[YtDlpManager] Failed to set permissions: $e');
      }
    }
  }
  
  /// Get current version info
  String? get currentVersion => _currentVersion;
  
  /// Check if yt-dlp is installed
  bool get isInstalled => _binaryPath != null && File(_binaryPath!).existsSync();
}
