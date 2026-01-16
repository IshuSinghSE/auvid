import 'package:flutter/material.dart';
import 'dart:io';
import '../services/download_service.dart';
import '../core/models.dart';

class DownloadProvider extends ChangeNotifier {
  final DownloadService _downloadService = DownloadService();
  
  // State variables
  DownloadMode _mode = DownloadMode.video;
  ScreenState _screenState = ScreenState.input;
  
  String _url = '';
  VideoInfo? _videoInfo;
  FormatInfo? _selectedFormat;
  String? _selectedQuality;
  String? _selectedFormatExt;
  bool _extractAudio = false;
  String _audioFormat = 'mp3';
  
  bool _isDownloading = false;
  bool _isFetchingInfo = false;
  double _progress = 0.0;
  String _statusMessage = '';
  String _downloadSpeed = '';
  String _fileSize = '';
  String _timeRemaining = '';
  String _downloadPath = '';
  Process? _downloadProcess;

  // Getters
  DownloadMode get mode => _mode;
  ScreenState get screenState => _screenState;
  VideoInfo? get videoInfo => _videoInfo;
  FormatInfo? get selectedFormat => _selectedFormat;
  String? get selectedQuality => _selectedQuality;
  String? get selectedFormatExt => _selectedFormatExt;
  bool get extractAudio => _extractAudio;
  String get audioFormat => _audioFormat;
  bool get isDownloading => _isDownloading;
  bool get isFetchingInfo => _isFetchingInfo;
  double get progress => _progress;
  String get statusMessage => _statusMessage;
  String get downloadSpeed => _downloadSpeed;
  String get fileSize => _fileSize;
  String get timeRemaining => _timeRemaining;
  String get downloadPath => _downloadPath;

  // Setters
  void setMode(DownloadMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    
    // Pre-select default format for new mode to avoid flickering
    if (_videoInfo != null) {
      final qualityOptions = getQualityOptions();
      final formatOptions = getFormatOptions();
      if (qualityOptions.isNotEmpty && formatOptions.isNotEmpty) {
        updateSelectedFormat(qualityOptions.first, formatOptions.first);
      }
    }
    
    notifyListeners();
  }

  void setExtractAudio(bool value) {
    _extractAudio = value;
    notifyListeners();
  }

  void setAudioFormat(String format) {
    _audioFormat = format;
    notifyListeners();
  }

  // Fetch video information
  Future<void> fetchVideoInfo(String url) async {
    if (url.isEmpty) {
      _statusMessage = 'Please enter a URL';
      notifyListeners();
      return;
    }

    _url = url;
    _isFetchingInfo = true;
    _statusMessage = 'Fetching video information...';
    _videoInfo = null;
    notifyListeners();

    try {
      final info = await _downloadService.getVideoInfo(url);
      if (info != null) {
        _videoInfo = info;
        _screenState = ScreenState.formatSelection;
        _isFetchingInfo = false;
        _statusMessage = '';
        notifyListeners();
      } else {
        _isFetchingInfo = false;
        _statusMessage = 'Could not fetch video info';
        notifyListeners();
      }
    } catch (e) {
      _isFetchingInfo = false;
      _statusMessage = 'Error: $e';
      notifyListeners();
    }
  }

  // Start download
  Future<void> startDownload() async {
    if (_selectedFormat == null) {
      _statusMessage = 'Please select a format';
      notifyListeners();
      return;
    }

    _screenState = ScreenState.downloading;
    _isDownloading = true;
    _progress = 0.0;
    _statusMessage = 'Starting download...';
    notifyListeners();

    try {
      // Extract quality number from format (e.g., "1080p" -> "1080")
      final qualityStr = _selectedFormat!.quality.replaceAll(RegExp(r'[^0-9]'), '');
      final quality = qualityStr.isNotEmpty ? qualityStr : '720';
      
      await for (final data in _downloadService.downloadVideoWithProgress(
        _url,
        quality,
        extractAudio: _extractAudio,
        audioFormat: _audioFormat,
      )) {
        _progress = data['progress'] ?? 0.0;
        _downloadSpeed = data['speed'] ?? '';
        _fileSize = data['fileSize'] ?? '';
        _timeRemaining = data['eta'] ?? '';
        _downloadPath = data['path'] ?? '';
        notifyListeners();
      }

      _isDownloading = false;
      _screenState = ScreenState.complete;
      _statusMessage = 'Download finished';
      notifyListeners();
    } catch (e) {
      _isDownloading = false;
      _screenState = ScreenState.formatSelection;
      _statusMessage = 'Error: $e';
      notifyListeners();
    }
  }

  // Cancel download
  void cancelDownload() {
    _downloadProcess?.kill();
    _isDownloading = false;
    _screenState = ScreenState.formatSelection;
    _progress = 0.0;
    _statusMessage = 'Download cancelled';
    notifyListeners();
  }

  // Open download location
  void openDownloadLocation() {
    if (_downloadPath.isNotEmpty) {
      final dir = Directory(_downloadPath).parent.path;
      Process.run('xdg-open', [dir]);
    }
  }

  // Reset to initial state
  void reset() {
    _screenState = ScreenState.input;
    _videoInfo = null;
    _selectedFormat = null;
    _selectedQuality = null;
    _selectedFormatExt = null;
    _isDownloading = false;
    _isFetchingInfo = false;
    _progress = 0.0;
    _statusMessage = '';
    notifyListeners();
  }

  // Get quality options
  List<String> getQualityOptions() {
    if (_videoInfo == null) return [];
    
    final formats = _mode == DownloadMode.audio 
        ? _videoInfo!.audioFormats 
        : _videoInfo!.videoFormats;
    
    final qualities = formats.map((f) => f.quality).toSet().toList();
    
    if (_mode == DownloadMode.video) {
      qualities.sort((a, b) {
        final aHeight = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bHeight = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return bHeight.compareTo(aHeight);
      });
    } else {
      qualities.sort((a, b) {
        final aBitrate = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bBitrate = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return bBitrate.compareTo(aBitrate);
      });
    }
    
    return qualities;
  }

  // Get format options
  List<String> getFormatOptions() {
    if (_videoInfo == null) return [];
    
    final formats = _mode == DownloadMode.audio 
        ? _videoInfo!.audioFormats 
        : _videoInfo!.videoFormats;
    
    final extensions = formats.map((f) => f.ext).toSet().toList();
    extensions.sort();
    
    return extensions;
  }

  // Update selected format
  void updateSelectedFormat(String quality, String formatExt) {
    _selectedQuality = quality;
    _selectedFormatExt = formatExt;
    
    final formats = _mode == DownloadMode.audio 
        ? _videoInfo!.audioFormats 
        : _videoInfo!.videoFormats;
    
    final matchingFormats = formats.where((f) => 
      f.quality == quality && f.ext == formatExt
    ).toList();
    
    if (matchingFormats.isNotEmpty) {
      _selectedFormat = matchingFormats.first;
    } else {
      final qualityMatches = formats.where((f) => f.quality == quality).toList();
      if (qualityMatches.isNotEmpty) {
        _selectedFormat = qualityMatches.first;
        _selectedFormatExt = _selectedFormat!.ext;
      }
    }
    notifyListeners();
  }
}
