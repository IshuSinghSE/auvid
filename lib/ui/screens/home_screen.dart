import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/download_provider.dart';
import '../../core/models.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../widgets/glass_input.dart';
import '../widgets/action_button.dart';
import '../widgets/thumbnail_preview.dart';
import '../widgets/cool_progress_bar.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DownloadProvider(),
      child: Consumer<DownloadProvider>(
        builder: (context, provider, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Builder(
              builder: (context) {
                if (provider.isFetchingInfo) {
                  return const LoadingScreen(key: ValueKey('loading'));
                }

                switch (provider.screenState) {
                  case ScreenState.input:
                    return const InputScreen(key: ValueKey('input'));
                  case ScreenState.formatSelection:
                    return const FormatSelectionScreen(key: ValueKey('format'));
                  case ScreenState.downloading:
                    return const DownloadingScreen(
                      key: ValueKey('downloading'),
                    );
                  case ScreenState.complete:
                    return const CompletionScreen(key: ValueKey('complete'));
                }
              },
            ),
          );
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
  final _urlRegex = RegExp(r'https?://\S+');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _urlController.addListener(() {
        final text = _urlController.text.trim();
        if (text.isEmpty) return;
        if (_urlRegex.hasMatch(text)) {
          final provider = Provider.of<DownloadProvider>(
            context,
            listen: false,
          );
          if (!provider.isFetchingInfo &&
              provider.screenState == ScreenState.input) {
            provider.fetchVideoInfo(text);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DownloadProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: AppConstants.inputScreenWidth,
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(AppConstants.spacingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo_icon.png',
                    width: 128,
                    height: 128,
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appTitle,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1.5,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConstants.appSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingXXLarge),

              _buildCard(
                context,
                child: Column(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: AppStyles.borderRadiusMedium,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: GlassInput(
                            controller: _urlController,
                            hintText: AppConstants.urlHint,
                            prefixIcon: Icons.link,
                            onSubmitted: (_) =>
                                provider.fetchVideoInfo(_urlController.text),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    ActionButton(
                      onPressed: () =>
                          provider.fetchVideoInfo(_urlController.text),
                      label: 'Continue',
                      isLoading: provider.isFetchingInfo,
                    ),
                  ],
                ),
              ),

              if (provider.statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppConstants.spacingLarge,
                  ),
                  child: Text(
                    provider.statusMessage,
                    style: TextStyle(
                      color: provider.statusMessage.startsWith('Error')
                          ? Colors.red
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

// ============================================================================
// Loading skeleton
// ============================================================================
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.inputScreenWidth,
          ),
          padding: const EdgeInsets.all(AppConstants.spacingXLarge),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surface
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                final shimmerPos = (_ctrl.value * 2) - 1;
                return ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment(-1 - shimmerPos, 0),
                      end: Alignment(1 - shimmerPos, 0),
                      colors: [base, base.withOpacity(0.4), base],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: AppConstants.thumbnailHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Container(
                        height: 20,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 14,
                        width: MediaQuery.of(context).size.width * 0.35,
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final provider = Provider.of<DownloadProvider>(context, listen: false);
        provider.setMode(
          _tabController.index == 0 ? DownloadMode.audio : DownloadMode.video,
        );
      }
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

    if (provider.selectedFormat == null &&
        qualityOptions.isNotEmpty &&
        formatOptions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (provider.selectedFormat == null) {
          provider.updateSelectedFormat(
            qualityOptions.first,
            formatOptions.first,
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: provider.reset,
          tooltip: 'Back',
        ),
        title: const Text('Download'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Center(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicatorPadding: EdgeInsets.zero,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: const [
                Tab(
                  height: 40,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.audiotrack, size: 18),
                        SizedBox(width: 6),
                        Text('Audio'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  height: 40,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, size: 18),
                        SizedBox(width: 6),
                        Text('Video'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: LayoutBuilder(
          key: ValueKey('${provider.mode}_${provider.selectedQuality}'),
          builder: (context, constraints) {
            final isWide =
                constraints.maxWidth > AppConstants.wideLayoutBreakpoint;
            if (isWide) {
              return _buildWideLayout(
                context,
                provider,
                qualityOptions,
                formatOptions,
              );
            } else {
              return _buildNarrowLayout(
                context,
                provider,
                  qualityOptions,
                  formatOptions,
                );
              }
            },
          ),
        ),
      );
  }

  Widget _buildWideLayout(
    BuildContext context,
    DownloadProvider provider,
    List<String> qualityOptions,
    List<String> formatOptions,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.maxContentWidth,
        ),
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildCard(
                context,
                child: _buildVideoInfo(context, provider),
              ),
            ),
            const SizedBox(width: AppConstants.spacingXLarge),
            Expanded(
              flex: 3,
              child: _buildCard(
                context,
                child: _buildDownloadOptions(
                  context,
                  provider,
                  qualityOptions,
                  formatOptions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    DownloadProvider provider,
    List<String> qualityOptions,
    List<String> formatOptions,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          children: [
            _buildCard(context, child: _buildVideoInfo(context, provider)),
            const SizedBox(height: AppConstants.spacingLarge),
            _buildCard(
              context,
              child: _buildDownloadOptions(
                context,
                provider,
                qualityOptions,
                formatOptions,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
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
        const SizedBox(height: 24.0),
        SelectableText(
          provider.videoInfo!.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24.0),
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
    List<String> formatOptions,
  ) {
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
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Recommended',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null)
                provider.updateSelectedFormat(value, formatOptions.first);
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
            items: formatOptions
                .map(
                  (format) => DropdownMenuItem(
                    value: format,
                    child: Text(format.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null)
                provider.updateSelectedFormat(
                  provider.selectedQuality ?? qualityOptions.first,
                  value,
                );
            },
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          if (provider.selectedFormat != null)
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                    context,
                    'Quality',
                    provider.selectedFormat!.quality,
                  ),
                  _buildInfoRow(
                    context,
                    'Format',
                    provider.selectedFormat!.ext.toUpperCase(),
                  ),
                  _buildInfoRow(
                    context,
                    'File Size',
                    provider.selectedFormat!.filesize,
                  ),
                  _buildInfoRow(
                    context,
                    'Audio',
                    provider.selectedFormat!.hasAudio ? 'Included' : 'No audio',
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24.0),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: provider.cancelDownload,
          tooltip: 'Cancel Download',
        ),
        title: const Text('Downloading'),
        actions: [
          TextButton.icon(
            onPressed: provider.cancelDownload,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.inputScreenWidth,
          ),
          padding: const EdgeInsets.all(AppConstants.spacingXLarge),
          child: _buildCard(
            context,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Downloading',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24.0),
                if (provider.videoInfo != null)
                  SelectableText(
                    provider.videoInfo!.title,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                const SizedBox(height: 24.0),
                ThumbnailPreview(
                  imageUrl: provider.videoInfo?.thumbnail ?? '',
                  width: 320,
                  height: 180,
                ),
                const SizedBox(height: 24.0),
                CoolProgressBar(progress: provider.progress, height: 10),
                const SizedBox(height: AppConstants.spacingMedium),
                Text(
                  '${(provider.progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Text(
                  '${provider.timeRemaining} - ${provider.fileSize} (${provider.downloadSpeed})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: provider.reset,
        ),
        title: const Text('Download Complete'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.inputScreenWidth,
          ),
          padding: const EdgeInsets.all(AppConstants.spacingXLarge),
          child: _buildCard(
            context,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 24.0),
                const Text(
                  'Download Complete',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24.0),
                if (provider.videoInfo != null)
                  SelectableText(
                    provider.videoInfo!.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
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
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
