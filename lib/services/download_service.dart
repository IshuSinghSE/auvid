import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../core/models.dart';

class DownloadService {
  // Get comprehensive video information including available formats
  Future<VideoInfo?> getVideoInfo(String url) async {
    final cmd = _getBinaryCommandParts();
    final exe = cmd.first;
    final prefixArgs = cmd.length > 1 ? cmd.sublist(1) : <String>[];

    // Ensure binary has execute permissions if it's a file
    await _ensureExecutablePermissions(exe);

    try {
      final result = await Process.run(exe, [
        ...prefixArgs,
        '--dump-json',
        '--no-playlist',
        url,
      ]);

      if (result.exitCode == 0) {
        final json = jsonDecode(result.stdout);
        
        // Parse available formats
        final List<FormatInfo> videoFormats = [];
        final List<FormatInfo> audioFormats = [];
        
        if (json['formats'] != null) {
          for (var format in json['formats']) {
            final formatId = format['format_id']?.toString();
            final ext = format['ext']?.toString() ?? 'unknown';
            final filesize = format['filesize'] ?? format['filesize_approx'];
            final filesizeStr = filesize != null ? _formatFileSize(filesize) : 'Unknown size';
            
            if (format['vcodec'] != null && format['vcodec'] != 'none') {
              // Video format
              final height = format['height'];
              final fps = format['fps'];
              final acodec = format['acodec']?.toString() ?? 'no audio';
              
              if (height != null && formatId != null) {
                final quality = '${height}p${fps != null ? fps.round() : ""}';
                final description = '$quality ($ext) - $filesizeStr';
                
                videoFormats.add(FormatInfo(
                  formatId: formatId,
                  quality: quality,
                  description: description,
                  ext: ext,
                  filesize: filesizeStr,
                  hasAudio: acodec != 'none',
                ));
              }
            } else if (format['acodec'] != null && format['acodec'] != 'none') {
              // Audio-only format
              final abr = format['abr']; // audio bitrate
              
              if (formatId != null) {
                final quality = abr != null ? '${abr.round()}kbps' : 'Audio';
                final description = '$quality ($ext) - $filesizeStr';
                
                audioFormats.add(FormatInfo(
                  formatId: formatId,
                  quality: quality,
                  description: description,
                  ext: ext,
                  filesize: filesizeStr,
                  hasAudio: true,
                ));
              }
            }
          }
        }
        
        // Sort formats - highest quality first
        videoFormats.sort((a, b) {
          final aHeight = int.tryParse(a.quality.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final bHeight = int.tryParse(b.quality.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return bHeight.compareTo(aHeight);
        });
        
        audioFormats.sort((a, b) {
          final aBitrate = int.tryParse(a.quality.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final bBitrate = int.tryParse(b.quality.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return bBitrate.compareTo(aBitrate);
        });
        
        return VideoInfo(
          title: json['title'] ?? 'Unknown',
          thumbnail: json['thumbnail'] ?? '',
          duration: json['duration']?.toString() ?? '0',
          uploader: json['uploader'] ?? '',
          videoFormats: videoFormats,
          audioFormats: audioFormats,
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch video info: $e');
    }

    return null;
  }
  
  String _formatFileSize(dynamic bytes) {
    if (bytes == null) return 'Unknown size';
    final size = bytes is int ? bytes : int.tryParse(bytes.toString()) ?? 0;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  // Download with detailed progress information
  Stream<Map<String, dynamic>> downloadVideoWithProgress(
    String url,
    String quality, {
    bool extractAudio = false,
    String audioFormat = 'mp3',
    String? desiredExt,
  }) async* {
    final cmd = _getBinaryCommandParts();
    final exe = cmd.first;
    final prefixArgs = cmd.length > 1 ? cmd.sublist(1) : <String>[];
    await _ensureExecutablePermissions(exe);

    // Determine download directory (prefer Downloads, works with Flatpak xdg-download permission)
    final isFlatpak = Platform.environment['FLATPAK_ID'] != null;
    final home = Platform.environment['HOME'] ?? Directory.current.path;
    final downloadDir = Directory('${home}${Platform.pathSeparator}Downloads');
    if (!downloadDir.existsSync()) {
      try {
        downloadDir.createSync(recursive: true);
      } catch (_) {}
    }

    // Build the command with format preferences
    final outputTemplate = '${downloadDir.path}${Platform.pathSeparator}%(title)s.%(ext)s';
    // Ensure yt-dlp explicitly writes to the Downloads directory inside Flatpak
    final args = [
      '--newline',
      '--progress',
      '-P',
      downloadDir.path,
      '-o',
      outputTemplate,
    ];

    if (extractAudio) {
      // Extract audio from video
      args.addAll(['-x', '--audio-format', audioFormat]);
      args.addAll(['-f', 'bestaudio/best']);
    } else {
      // Video download - use format selection that yt-dlp can handle
      // This avoids the JavaScript runtime requirement
      args.addAll(['-S', 'res:$quality']);
      args.addAll(['-f', 'bv*[height<=$quality]+ba/b[height<=$quality]/bv*+ba/b']);
      if (desiredExt != null && desiredExt.isNotEmpty) {
        args.addAll(['--merge-output-format', desiredExt]);
      }
    }

    args.add(url);

    // Spawn the process
    final process = await Process.start(exe, [...prefixArgs, ...args]);

    // Yield initial progress
    yield {
      'progress': 0.0,
      'speed': '',
      'fileSize': '',
      'eta': '',
      'path': '',
    };

    // Collect stderr for error messages
    final stderrBuffer = StringBuffer();
    process.stderr.transform(systemEncoding.decoder).listen((data) {
      stderrBuffer.write(data);
      print('[yt-dlp stderr]: $data'); // Debug output
    });

    // Regex patterns for parsing progress
    final progressRegex = RegExp(r'\[download\]\s+(\d+\.?\d*)%');
    final speedRegex = RegExp(r'at\s+([^\s]+/s)');
    final sizeRegex = RegExp(r'of\s+([^\s]+)');
    final etaRegex = RegExp(r'ETA\s+(\d+:\d+:\d+|\d+:\d+)');
    final destinationRegex = RegExp(r'\[download\] Destination: (.+)');
    final mergerRegex = RegExp(r'\[Merger\] Merging formats into\s+"?([^"\n]+)"?');
    final deletingRegex = RegExp(r'Deleting original file (.+) \(pass -k to keep\)');

    String currentPath = '';
    
    await for (final line in process.stdout.transform(systemEncoding.decoder)) {
      print('[yt-dlp]: $line'); // Debug output
      
      // Extract destination path
      final destMatch = destinationRegex.firstMatch(line);
      if (destMatch != null) {
        currentPath = destMatch.group(1) ?? '';
      }

      // Capture the merged output name
      final mergeMatch = mergerRegex.firstMatch(line);
      if (mergeMatch != null) {
        currentPath = mergeMatch.group(1) ?? currentPath;
      }

      // Sometimes yt-dlp deletes originals after merging; use that to infer path if needed
      final delMatch = deletingRegex.firstMatch(line);
      if (delMatch != null && currentPath.isEmpty) {
        currentPath = delMatch.group(1) ?? '';
      }

      // Extract progress percentage
      final progressMatch = progressRegex.firstMatch(line);
      if (progressMatch != null) {
        final percentageStr = progressMatch.group(1);
        if (percentageStr != null) {
          final percentage = double.parse(percentageStr) / 100.0;

          // Extract other metrics
          final speedMatch = speedRegex.firstMatch(line);
          final sizeMatch = sizeRegex.firstMatch(line);
          final etaMatch = etaRegex.firstMatch(line);

          yield {
            'progress': percentage,
            'speed': speedMatch?.group(1) ?? '',
            'fileSize': sizeMatch?.group(1) ?? '',
            'eta': etaMatch?.group(1) ?? '0:00:00',
            'path': currentPath,
          };
        }
      }
    }

    // Wait for process to complete
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final errors = stderrBuffer.toString();
      throw Exception('Download failed: $errors');
    }
    
    // Signal completion
    yield {
      'progress': 1.0,
      'speed': '',
      'fileSize': '',
      'eta': '0:00:00',
      'path': currentPath,
    };
  }

  Stream<double> downloadVideo(String url, String quality) async* {
    // Locate the yt-dlp binary
    final cmd = _getBinaryCommandParts();
    final exe = cmd.first;
    final prefixArgs = cmd.length > 1 ? cmd.sublist(1) : <String>[];
    await _ensureExecutablePermissions(exe);

    // Determine download directory (prefer Downloads, works with Flatpak xdg-download permission)
    final home = Platform.environment['HOME'] ?? Directory.current.path;
    final downloadDir = Directory('${home}${Platform.pathSeparator}Downloads');
    if (!downloadDir.existsSync()) {
      try {
        downloadDir.createSync(recursive: true);
      } catch (_) {}
    }

    // Build the command
    final args = [
      '--newline',
      '-P',
      downloadDir.path,
      '-f',
      _getFormatString(quality),
      url,
    ];

    // Spawn the background process
    final process = await Process.start(exe, [...prefixArgs, ...args]);

    // Regex to extract progress percentage
    final progressRegex = RegExp(r'\[download\]\s+(\d+\.?\d*)%');

    // Listen to stdout stream
    await for (final line in process.stdout.transform(systemEncoding.decoder)) {
      final match = progressRegex.firstMatch(line);
      if (match != null) {
        final percentageStr = match.group(1);
        if (percentageStr != null) {
          final percentage = double.parse(percentageStr) / 100.0;
          yield percentage;
        }
      }
    }

    // Wait for process to complete
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final errors = await process.stderr.transform(systemEncoding.decoder).join();
      throw Exception('Download failed with exit code $exitCode: $errors');
    }

    // Signal completion
    yield 1.0;
  }

  String _getBinaryPath() {
    if (Platform.isWindows) {
      return 'bin/yt-dlp.exe';
    } else if (Platform.isMacOS) {
      return 'bin/yt-dlp_macos';
    } else if (Platform.isLinux) {
      return 'bin/yt-dlp_linux';
    } else{
      return 'bin/yt-dlp';
    }
  }

  List<String> _getBinaryCommandParts() {
    if (Platform.isWindows) {
      return ['bin/yt-dlp.exe'];
    } else if (Platform.isMacOS) {
      return ['bin/yt-dlp_macos'];
    } else if (Platform.isLinux) {
      final candidates = [
        'bin/yt-dlp_linux',
        '/app/bin/bin/yt-dlp_linux',
        '/app/bin/yt-dlp_linux',
        'yt-dlp',
      ];
      for (final p in candidates) {
        try {
          if (File(p).existsSync()) return [p];
        } catch (_) {}
      }
      return ['python3', '-m', 'yt_dlp'];
    } else {
      return ['bin/yt-dlp'];
    }
  }

  Future<void> _ensureExecutablePermissions(String binaryPath) async {
    if (!Platform.isWindows) {
      try {
        // Only chmod if the path is an existing file
        if (File(binaryPath).existsSync()) {
          await Process.run('chmod', ['+x', binaryPath]);
        }
      } catch (e) {
        // Permissions already set or chmod not available
      }
    }
  }

  String _getFormatString(String quality) {
    switch (quality) {
      case '2160p':
        return 'bestvideo[height<=2160]+bestaudio/best';
      case '1440p':
        return 'bestvideo[height<=1440]+bestaudio/best';
      case '1080p':
        return 'bestvideo[height<=1080]+bestaudio/best';
      case '720p':
        return 'bestvideo[height<=720]+bestaudio/best';
      case '480p':
        return 'bestvideo[height<=480]+bestaudio/best';
      case '360p':
        return 'bestvideo[height<=360]+bestaudio/best';
      case 'Audio Only':
        return 'bestaudio';
      default:
        return 'bestvideo+bestaudio/best';
    }
  }
}
