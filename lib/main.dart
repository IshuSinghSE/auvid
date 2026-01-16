import 'package:flutter/material.dart';
import 'dart:io';
import 'services/download_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const DownloaderPage(),
    );
  }
}

class DownloaderPage extends StatefulWidget {
  const DownloaderPage({super.key});

  @override
  State<DownloaderPage> createState() => _DownloaderPageState();
}

enum DownloadMode { audio, video }

class _DownloaderPageState extends State<DownloaderPage> with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController();
  final _downloadService = DownloadService();
  late TabController _tabController;

  DownloadMode _mode = DownloadMode.video;
  String _selectedQuality = '1080p (HD)';
  bool _preferMpeg = false;
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusMessage = '';
  bool _downloadComplete = false;
  String _videoTitle = '';
  String _thumbnailUrl = '';
  String _downloadSpeed = '';
  String _fileSize = '';
  String _timeRemaining = '';
  String _downloadPath = '';
  Process? _downloadProcess;

  final Map<String, String> _videoQualities = {
    '2160p (4K)': '2160p',
    '1440p (QHD)': '1440p',
    '1080p (HD)': '1080p',
    '720p (HD)': '720p',
    '480p': '480p',
    '360p': '360p',
  };

  final Map<String, String> _audioQualities = {
    'Best': 'best',
    '320kbps': '320k',
    '256kbps': '256k',
    '192kbps': '192k',
    '128kbps': '128k',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _mode = _tabController.index == 0 ? DownloadMode.audio : DownloadMode.video;
        _selectedQuality = _mode == DownloadMode.audio ? 'Best' : '1080p (HD)';
      });
    });
  }

  Future<void> _fetchVideoInfo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    try {
      final info = await _downloadService.getVideoInfo(url);
      setState(() {
        _videoTitle = info['title'] ?? 'Unknown Title';
        _thumbnailUrl = info['thumbnail'] ?? '';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Could not fetch video info';
      });
    }
  }

  void _startDownload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a URL';
      });
      return;
    }

    // Fetch video info first
    await _fetchVideoInfo();

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _statusMessage = 'Starting download...';
      _downloadComplete = false;
    });

    try {
      final quality = _mode == DownloadMode.audio 
          ? _audioQualities[_selectedQuality] ?? 'best'
          : _videoQualities[_selectedQuality] ?? '1080p';

      await for (final data in _downloadService.downloadVideoWithProgress(
        url, 
        quality,
        audioOnly: _mode == DownloadMode.audio,
        preferMpeg: _preferMpeg,
      )) {
        setState(() {
          _progress = data['progress'] ?? 0.0;
          _downloadSpeed = data['speed'] ?? '';
          _fileSize = data['fileSize'] ?? '';
          _timeRemaining = data['eta'] ?? '';
          _downloadPath = data['path'] ?? '';
        });
      }

      setState(() {
        _isDownloading = false;
        _downloadComplete = true;
        _statusMessage = 'Download finished';
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadComplete = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  void _cancelDownload() {
    _downloadProcess?.kill();
    setState(() {
      _isDownloading = false;
      _downloadComplete = false;
      _progress = 0.0;
      _statusMessage = 'Download cancelled';
    });
  }

  void _openDownloadLocation() {
    if (_downloadPath.isNotEmpty) {
      final dir = Directory(_downloadPath).parent.path;
      Process.run('xdg-open', [dir]);
    }
  }

  void _reset() {
    setState(() {
      _isDownloading = false;
      _downloadComplete = false;
      _progress = 0.0;
      _statusMessage = '';
      _videoTitle = '';
      _thumbnailUrl = '';
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tabController.dispose();
    _downloadProcess?.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_downloadComplete) {
      return _buildCompletionScreen(context);
    }
    
    if (_isDownloading) {
      return _buildDownloadingScreen(context);
    }

    return _buildInputScreen(context);
  }

  Widget _buildInputScreen(BuildContext context) {
    final qualities = _mode == DownloadMode.audio 
        ? _audioQualities.keys.toList() 
        : _videoQualities.keys.toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.audiotrack), text: 'Audio'),
            Tab(icon: Icon(Icons.videocam), text: 'Video'),
          ],
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // URL Input Field
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.contains('youtube.com') || value.contains('youtu.be')) {
                    _fetchVideoInfo();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Resolution Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedQuality,
                decoration: const InputDecoration(
                  labelText: 'Resolution',
                  border: OutlineInputBorder(),
                ),
                items: qualities.map((quality) {
                  return DropdownMenuItem(
                    value: quality,
                    child: Text(quality),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuality = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Prefer MPEG Format Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Prefer MPEG format',
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(
                    value: _preferMpeg,
                    onChanged: (value) {
                      setState(() {
                        _preferMpeg = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Download Button
              ElevatedButton(
                onPressed: _startDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Download',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // Error Message
              if (_statusMessage.isNotEmpty && !_isDownloading)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.startsWith('Error') ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadingScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: TextButton(
          onPressed: _cancelDownload,
          child: const Text('Cancel'),
        ),
        title: const Text('Video Downloader'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Downloading',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              if (_videoTitle.isNotEmpty)
                Text(
                  _videoTitle,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),

              // Thumbnail placeholder
              if (_thumbnailUrl.isNotEmpty)
                Container(
                  width: 320,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, size: 64, color: Colors.grey),
                )
              else
                Container(
                  width: 320,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.videocam, size: 64, color: Colors.grey),
                ),
              const SizedBox(height: 32),

              // Progress Bar
              LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              // Progress Text
              Text(
                '$_timeRemaining - $_fileSize ($_downloadSpeed)',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _reset,
        ),
        title: const Text('Video Downloader'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.download,
                size: 64,
                color: Colors.black87,
              ),
              const SizedBox(height: 24),
              const Text(
                'Download finished',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              if (_videoTitle.isNotEmpty)
                Text(
                  _videoTitle,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),

              // Open Download Location Button
              ElevatedButton(
                onPressed: _openDownloadLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Open Download Location'),
              ),
              const SizedBox(height: 32),

              // Details Expandable
              ExpansionTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Details'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quality: $_selectedQuality'),
                        const SizedBox(height: 8),
                        Text('Format: ${_preferMpeg ? "MPEG" : "Default"}'),
                        const SizedBox(height: 8),
                        Text('Path: $_downloadPath'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
