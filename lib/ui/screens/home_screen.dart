import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/download_provider.dart';
import '../../core/models.dart';
import '../../core/constants.dart';
import '../widgets/glass_input.dart';
import '../widgets/action_button.dart';
import '../widgets/thumbnail_preview.dart';
import '../widgets/cool_progress_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DownloadProvider(),
      child: Consumer<DownloadProvider>(
        builder: (context, provider, _) {
          switch (provider.screenState) {
            case ScreenState.input:
              return const InputScreen();
            case ScreenState.formatSelection:
              return const FormatSelectionScreen();
            case ScreenState.downloading:
              return const DownloadingScreen();
            case ScreenState.complete:
              return const CompletionScreen();
          }
        },
      ),
    );
  }
}

// ============================================================================
// INPUT SCREEN
// ============================================================================
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DownloadProvider>(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: AppConstants.inputScreenWidth,
          padding: const EdgeInsets.all(AppConstants.spacingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appTitle,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.5,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                AppConstants.appSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingXXLarge),
              GlassInput(
                controller: _urlController,
                hintText: AppConstants.urlHint,
                prefixIcon: Icons.link,
                onSubmitted: (_) => provider.fetchVideoInfo(_urlController.text),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              ActionButton(
                onPressed: () => provider.fetchVideoInfo(_urlController.text),
                label: 'Continue',
                isLoading: provider.isFetchingInfo,
              ),
              if (provider.statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppConstants.spacingLarge),
                  child: Text(
                    provider.statusMessage,
                    style: TextStyle(
                      color: provider.statusMessage.startsWith('Error')
                          ? Colors.red
                          : Colors.grey,
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
}

// ============================================================================
// FORMAT SELECTION SCREEN
// ============================================================================
class FormatSelectionScreen extends StatefulWidget {
  const FormatSelectionScreen({super.key});

  @override
  State<FormatSelectionScreen> createState() => _FormatSelectionScreenState();
}

class _FormatSelectionScreenState extends State<FormatSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      final provider = Provider.of<DownloadProvider>(context, listen: false);
      provider.setMode(_tabController.index == 0
          ? DownloadMode.audio
          : DownloadMode.video);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DownloadProvider>(context);
    if (provider.videoInfo == null) return const SizedBox();

    final qualityOptions = provider.getQualityOptions();
    final formatOptions = provider.getFormatOptions();

    // Set default selections
    if (provider.selectedFormat == null && qualityOptions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.updateSelectedFormat(qualityOptions.first, formatOptions.first);
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: provider.reset,
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
          final isWide = constraints.maxWidth > AppConstants.wideLayoutBreakpoint;

          if (isWide) {
            return _buildWideLayout(
                context, provider, qualityOptions, formatOptions);
          } else {
            return _buildNarrowLayout(
                context, provider, qualityOptions, formatOptions);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, DownloadProvider provider,
      List<String> qualityOptions, List<String> formatOptions) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildVideoInfo(context, provider)),
            const SizedBox(width: AppConstants.spacingXLarge),
            Expanded(
              flex: 3,
              child: _buildDownloadOptions(
                  context, provider, qualityOptions, formatOptions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, DownloadProvider provider,
      List<String> qualityOptions, List<String> formatOptions) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          children: [
            _buildVideoInfo(context, provider),
            const SizedBox(height: AppConstants.spacingLarge),
            _buildDownloadOptions(
                context, provider, qualityOptions, formatOptions),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo(BuildContext context, DownloadProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThumbnailPreview(
          imageUrl: provider.videoInfo!.thumbnail,
          height: AppConstants.thumbnailHeight,
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        Text(
          provider.videoInfo!.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        if (provider.videoInfo!.uploader.isNotEmpty)
          Text(
            provider.videoInfo!.uploader,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadOptions(
      BuildContext context,
      DownloadProvider provider,
      List<String> qualityOptions,
      List<String> formatOptions) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Quality',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.high_quality),
              helperText: 'Select video quality',
            ),
            value: provider.selectedQuality,
            items: qualityOptions.map((quality) {
              final isRecommended = quality == qualityOptions.first;
              return DropdownMenuItem(
                value: quality,
                child: Row(
                  children: [
                    Text(quality),
                    if (isRecommended) ...[
                      const SizedBox(width: AppConstants.spacingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Recommended',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
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
                provider.updateSelectedFormat(value, formatOptions.first);
              }
            },
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Format',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.video_file),
              helperText: 'Select file format',
            ),
            value: provider.selectedFormatExt,
            items: formatOptions.map((format) {
              return DropdownMenuItem(
                value: format,
                child: Text(format.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                provider.updateSelectedFormat(
                    provider.selectedQuality ?? qualityOptions.first, value);
              }
            },
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          if (provider.selectedFormat != null)
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.5),
                borderRadius: AppStyles.borderRadiusSmall,
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
                      const SizedBox(width: AppConstants.spacingSmall),
                      const Text(
                        'Download Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _buildInfoRow(
                      context, 'Quality', provider.selectedFormat!.quality),
                  _buildInfoRow(context, 'Format',
                      provider.selectedFormat!.ext.toUpperCase()),
                  _buildInfoRow(
                      context, 'File Size', provider.selectedFormat!.filesize),
                  _buildInfoRow(
                    context,
                    'Audio',
                    provider.selectedFormat!.hasAudio
                        ? 'Included'
                        : 'No audio',
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppConstants.spacingLarge),
          ActionButton(
            onPressed: provider.selectedFormat == null
                ? null
                : () => provider.startDownload(),
            label: 'Download',
            icon: Icons.download,
          ),
          if (provider.statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacingMedium),
              child: Text(
                provider.statusMessage,
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
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DOWNLOADING SCREEN
// ============================================================================
class DownloadingScreen extends StatelessWidget {
  const DownloadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DownloadProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: TextButton(
          onPressed: provider.cancelDownload,
          child: const Text('Cancel'),
        ),
        title: const Text('Downloading'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppConstants.inputScreenWidth),
          padding: const EdgeInsets.all(AppConstants.spacingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Downloading',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              if (provider.videoInfo != null)
                Text(
                  provider.videoInfo!.title,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppConstants.spacingLarge),
              ThumbnailPreview(
                imageUrl: provider.videoInfo?.thumbnail ?? '',
                width: 320,
                height: 180,
              ),
              const SizedBox(height: AppConstants.spacingXLarge),
              CoolProgressBar(
                progress: provider.progress,
                height: 10,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                '${(provider.progress * 100).toStringAsFixed(1)}%',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                '${provider.timeRemaining} - ${provider.fileSize} (${provider.downloadSpeed})',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// COMPLETION SCREEN
// ============================================================================
class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DownloadProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: provider.reset,
        ),
        title: const Text('Download Complete'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppConstants.inputScreenWidth),
          padding: const EdgeInsets.all(AppConstants.spacingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingLarge),
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
              const SizedBox(height: AppConstants.spacingXLarge),
              const Text(
                'Download Complete',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              if (provider.videoInfo != null)
                Text(
                  provider.videoInfo!.title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppConstants.spacingXXLarge),
              ActionButton(
                onPressed: provider.openDownloadLocation,
                label: 'Open Folder',
                icon: Icons.folder_open,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              ActionButton(
                onPressed: provider.reset,
                label: 'Download Another',
                icon: Icons.add,
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
