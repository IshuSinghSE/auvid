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

enum ScreenState { input, formatSelection, downloading, complete }

class _DownloaderPageState extends State<DownloaderPage> with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController();
  final _downloadService = DownloadService();
  late TabController _tabController;

  DownloadMode _mode = DownloadMode.video;
  ScreenState _screenState = ScreenState.input;
  
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _mode = _tabController.index == 0 ? DownloadMode.audio : DownloadMode.video;
        _selectedFormat = null;
        _selectedQuality = null;
        _selectedFormatExt = null;
      });
    });
  }

  Future<void> _fetchVideoInfo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a URL';
      });
      return;
    }

    setState(() {
      _isFetchingInfo = true;
      _statusMessage = 'Fetching video information...';
      _videoInfo = null;
    });

    try {
      final info = await _downloadService.getVideoInfo(url);
      if (info != null) {
        setState(() {
          _videoInfo = info;
          _screenState = ScreenState.formatSelection;
          _isFetchingInfo = false;
          _statusMessage = '';
        });
      } else {
        setState(() {
          _isFetchingInfo = false;
          _statusMessage = 'Could not fetch video info';
        });
      }
    } catch (e) {
      setState(() {
        _isFetchingInfo = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  void _startDownload() async {
    if (_selectedFormat == null) {
      setState(() {
        _statusMessage = 'Please select a format';
      });
      return;
    }

    setState(() {
      _screenState = ScreenState.downloading;
      _isDownloading = true;
      _progress = 0.0;
      _statusMessage = 'Starting download...';
    });

    try {
      final url = _urlController.text.trim();
      // Extract quality number from format (e.g., "1080p" -> "1080")
      final qualityStr = _selectedFormat!.quality.replaceAll(RegExp(r'[^0-9]'), '');
      final quality = qualityStr.isNotEmpty ? qualityStr : '720';
      
      await for (final data in _downloadService.downloadVideoWithProgress(
        url,
        quality,
        extractAudio: _extractAudio,
        audioFormat: _audioFormat,
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
        _screenState = ScreenState.complete;
        _statusMessage = 'Download finished';
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _screenState = ScreenState.formatSelection;
        _statusMessage = 'Error: $e';
      });
    }
  }

  void _cancelDownload() {
    _downloadProcess?.kill();
    setState(() {
      _isDownloading = false;
      _screenState = ScreenState.formatSelection;
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
      _screenState = ScreenState.input;
      _videoInfo = null;
      _selectedFormat = null;
      _selectedQuality = null;
      _selectedFormatExt = null;
      _isDownloading = false;
      _isFetchingInfo = false;
      _progress = 0.0;
      _statusMessage = '';
      _urlController.clear();
    });
  }

  void _backToSelection() {
    setState(() {
      _screenState = ScreenState.formatSelection;
      _selectedFormat = null;
      _progress = 0.0;
      _statusMessage = '';
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
    switch (_screenState) {
      case ScreenState.input:
        return _buildInputScreen(context);
      case ScreenState.formatSelection:
        return _buildFormatSelectionScreen(context);
      case ScreenState.downloading:
        return _buildDownloadingScreen(context);
      case ScreenState.complete:
        return _buildCompletionScreen(context);
    }
  }

  Widget _buildInputScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Video Downloader'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.cloud_download, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Enter Video URL',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // URL Input Field
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                onSubmitted: (_) => _fetchVideoInfo(),
              ),
              const SizedBox(height: 24),

              // Fetch Button
              ElevatedButton(
                onPressed: _isFetchingInfo ? null : _fetchVideoInfo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isFetchingInfo
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
              ),

              // Error Message
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.startsWith('Error') ? Colors.red : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildFormatSelectionScreen(BuildContext context) {
    if (_videoInfo == null) return const SizedBox();

    // Group formats by quality for simpler selection
    final qualityOptions = _getQualityOptions();
    final formatOptions = _getFormatOptions();
    
    // Set default selections
    if (_selectedFormat == null && qualityOptions.isNotEmpty) {
      // Select best quality by default
      final bestQuality = qualityOptions.first;
      _updateSelectedFormat(bestQuality, formatOptions.first);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _reset,
        ),
        title: const Text('Download'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.audiotrack), text: 'Audio'),
            Tab(icon: Icon(Icons.videocam), text: 'Video'),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          if (isWide) {
            return _buildWideLayout(context, qualityOptions, formatOptions);
          } else {
            return _buildNarrowLayout(context, qualityOptions, formatOptions);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, List<String> qualityOptions, List<String> formatOptions) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Thumbnail and Info
            Expanded(
              flex: 2,
              child: _buildVideoInfo(context),
            ),
            const SizedBox(width: 32),
            // Right side - Options
            Expanded(
              flex: 3,
              child: _buildDownloadOptions(context, qualityOptions, formatOptions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, List<String> qualityOptions, List<String> formatOptions) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildVideoInfo(context),
            const SizedBox(height: 24),
            _buildDownloadOptions(context, qualityOptions, formatOptions),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        if (_videoInfo!.thumbnail.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _videoInfo!.thumbnail,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, size: 64),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.videocam, size: 64),
          ),
        const SizedBox(height: 16),
        
        // Title
        Text(
          _videoInfo!.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Uploader
        if (_videoInfo!.uploader.isNotEmpty)
          Text(
            _videoInfo!.uploader,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadOptions(BuildContext context, List<String> qualityOptions, List<String> formatOptions) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Quality Dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Quality',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.high_quality),
            helperText: 'Select video quality',
          ),
          value: _selectedQuality,
          items: qualityOptions.map((quality) {
            final isRecommended = quality == qualityOptions.first;
            return DropdownMenuItem(
              value: quality,
              child: Row(
                children: [
                  Text(quality),
                  if (isRecommended) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _updateSelectedFormat(value, formatOptions.first);
              });
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Format Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Format',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.video_file),
            helperText: 'Select file format',
          ),
          initialValue: _selectedFormatExt,
          items: formatOptions.map((format) {
            return DropdownMenuItem(
              value: format,
              child: Text(format.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _updateSelectedFormat(_selectedQuality ?? qualityOptions.first, value);
              });
            }
          },
        ),
        const SizedBox(height: 24),
        
        // Selected format info card
        if (_selectedFormat != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Download Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(context, 'Quality', _selectedFormat!.quality),
                _buildInfoRow(context, 'Format', _selectedFormat!.ext.toUpperCase()),
                _buildInfoRow(context, 'File Size', _selectedFormat!.filesize),
                _buildInfoRow(
                  context,
                  'Audio',
                  _selectedFormat!.hasAudio ? 'Included' : 'No audio',
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Download Button
        FilledButton.icon(
          onPressed: _selectedFormat == null ? null : _startDownload,
          icon: const Icon(Icons.download),
          label: const Text('Download'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        // Error Message
        if (_statusMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getQualityOptions() {
    final formats = _mode == DownloadMode.audio 
        ? _videoInfo!.audioFormats 
        : _videoInfo!.videoFormats;
    
    // Extract unique qualities and sort
    final qualities = formats.map((f) => f.quality).toSet().toList();
    
    if (_mode == DownloadMode.video) {
      // Sort video qualities from highest to lowest
      qualities.sort((a, b) {
        final aHeight = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bHeight = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return bHeight.compareTo(aHeight);
      });
    } else {
      // Sort audio qualities from highest to lowest bitrate
      qualities.sort((a, b) {
        final aBitrate = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bBitrate = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return bBitrate.compareTo(aBitrate);
      });
    }
    
    return qualities;
  }

  List<String> _getFormatOptions() {
    final formats = _mode == DownloadMode.audio 
        ? _videoInfo!.audioFormats 
        : _videoInfo!.videoFormats;
    
    // Extract unique extensions
    final extensions = formats.map((f) => f.ext).toSet().toList();
    extensions.sort();
    
    return extensions;
  }

  // String? _selectedQuality;
  // String? _selectedFormatExt;

  void _updateSelectedFormat(String quality, String formatExt) {
    _selectedQuality = quality;
    _selectedFormatExt = formatExt;
    
    final formats = _mode == DownloadMode.audio 
        ? _videoInfo!.audioFormats 
        : _videoInfo!.videoFormats;
    
    // Find format matching quality and extension
    final matchingFormats = formats.where((f) => 
      f.quality == quality && f.ext == formatExt
    ).toList();
    
    if (matchingFormats.isNotEmpty) {
      _selectedFormat = matchingFormats.first;
    } else {
      // Fallback: find any format with matching quality
      final qualityMatches = formats.where((f) => f.quality == quality).toList();
      if (qualityMatches.isNotEmpty) {
        _selectedFormat = qualityMatches.first;
        _selectedFormatExt = _selectedFormat!.ext;
      }
    }
  }

  Widget _buildDownloadingScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: TextButton(
          onPressed: _cancelDownload,
          child: const Text('Cancel'),
        ),
        title: const Text('Downloading'),
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
              
              if (_videoInfo != null)
                Text(
                  _videoInfo!.title,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 24),

              // Thumbnail
              if (_videoInfo?.thumbnail.isNotEmpty ?? false)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _videoInfo!.thumbnail,
                    width: 320,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 320,
                      height: 180,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Icon(Icons.image, size: 64),
                    ),
                  ),
                )
              else
                Container(
                  width: 320,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.videocam, size: 64),
                ),
              const SizedBox(height: 32),

              // Progress Bar
              LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
              ),
              const SizedBox(height: 16),

              // Progress Text
              Text(
                '${(_progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$_timeRemaining - $_fileSize ($_downloadSpeed)',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
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
          icon: const Icon(Icons.close),
          onPressed: _reset,
        ),
        title: const Text('Download Complete'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Download Complete',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Video title
              if (_videoInfo != null)
                Text(
                  _videoInfo!.title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 48),

              // Action Buttons
              FilledButton.icon(
                onPressed: _openDownloadLocation,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Folder'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.add),
                label: const Text('Download Another'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
