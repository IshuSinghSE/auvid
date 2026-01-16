/// Data models for auvid

enum DownloadMode { audio, video }

enum ScreenState { input, formatSelection, downloading, complete }

/// Represents comprehensive video information
class VideoInfo {
  final String title;
  final String thumbnail;
  final String duration;
  final String uploader;
  final List<FormatInfo> videoFormats;
  final List<FormatInfo> audioFormats;

  VideoInfo({
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.uploader,
    required this.videoFormats,
    required this.audioFormats,
  });

  // For compatibility with download_service.dart
  void operator [](String other) {}
}

/// Represents format information for a specific video/audio format
class FormatInfo {
  final String formatId;
  final String quality;
  final String description;
  final String ext;
  final String filesize;
  final bool hasAudio;

  FormatInfo({
    required this.formatId,
    required this.quality,
    required this.description,
    required this.ext,
    required this.filesize,
    required this.hasAudio,
  });
}

/// Represents download progress information
class DownloadProgress {
  final double progress;
  final String speed;
  final String fileSize;
  final String eta;
  final String path;

  DownloadProgress({
    required this.progress,
    required this.speed,
    required this.fileSize,
    required this.eta,
    required this.path,
  });

  factory DownloadProgress.fromMap(Map<String, dynamic> data) {
    return DownloadProgress(
      progress: data['progress'] ?? 0.0,
      speed: data['speed'] ?? '',
      fileSize: data['fileSize'] ?? '',
      eta: data['eta'] ?? '',
      path: data['path'] ?? '',
    );
  }
}
