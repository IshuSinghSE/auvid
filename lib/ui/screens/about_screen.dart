import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(AppConstants.spacingXLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                
                // App Name
                Text(
                  'auvid',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.5,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                
                // Version
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXLarge),
                
                // Description
                Text(
                  'A beautiful, modern audio and video downloader built with Flutter.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppConstants.spacingXXLarge),
                
                // Features
                _buildFeatureCard(
                  context,
                  icon: Icons.speed,
                  title: 'Fast Downloads',
                  description: 'Powered by yt-dlp for reliable, high-speed downloads',
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _buildFeatureCard(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Beautiful Design',
                  description: 'Modern, minimal interface with dark theme',
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _buildFeatureCard(
                  context,
                  icon: Icons.source,
                  title: 'Open Source',
                  description: 'Built with Flutter, free and open source',
                ),
                const SizedBox(height: AppConstants.spacingXXLarge),
                
                // Links
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppConstants.spacingMedium,
                  runSpacing: AppConstants.spacingMedium,
                  children: [
                    _buildLinkButton(
                      context,
                      icon: Icons.code,
                      label: 'Source Code',
                      onTap: () => _launchURL('https://github.com/IshuSinghSE/auvid'),
                    ),
                    _buildLinkButton(
                      context,
                      icon: Icons.bug_report_outlined,
                      label: 'Report Issue',
                      onTap: () => _launchURL('https://github.com/IshuSinghSE/auvid/issues'),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingXXLarge),
                
                // // Developer Info
                // Container(
                //   padding: const EdgeInsets.all(AppConstants.spacingLarge),
                //   decoration: BoxDecoration(
                //     color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                //   child: Column(
                //     children: [
                //       Text(
                //         'Developed by',
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                //         ),
                //       ),
                //       const SizedBox(height: AppConstants.spacingSmall),
                //       Text(
                //         'Ishu Singh',
                //         style: Theme.of(context).textTheme.titleLarge?.copyWith(
                //               fontWeight: FontWeight.bold,
                //             ),
                //       ),
                //       const SizedBox(height: AppConstants.spacingMedium),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           IconButton(
                //             icon: const Icon(Icons.public),
                //             onPressed: () => _launchURL('https://github.com/IshuSinghSE'),
                //             tooltip: 'GitHub Profile',
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: AppConstants.spacingLarge),
                
                // Copyright
                Text(
                  '© 2026 auvid. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLarge,
          vertical: AppConstants.spacingMedium,
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
