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
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXLarge,
              vertical: AppConstants.spacingLarge,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Icon
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        blurRadius: 50,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      width: 128,
                      height: 128,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                
                // App Name
                Text(
                  'auvid',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.0,
                      ),
                ),
                const SizedBox(height: 4),
                
                // Version
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                
                // Description
                Text(
                  'A beautiful, modern audio and video downloader.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                
                // Features
                _buildFeatureRow(
                  context,
                  icon: Icons.speed,
                  title: 'Fast',
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                _buildFeatureRow(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Beautiful',
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                _buildFeatureRow(
                  context,
                  icon: Icons.source,
                  title: 'Open Source',
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                
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

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
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
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
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
