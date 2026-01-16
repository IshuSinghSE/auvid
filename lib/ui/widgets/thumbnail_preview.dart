import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// An animated thumbnail/preview with shimmer effect
class ThumbnailPreview extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ThumbnailPreview({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height = AppConstants.thumbnailHeight,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppStyles.borderRadiusMedium;

    if (imageUrl.isEmpty) {
      return _buildPlaceholder(context, radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          boxShadow: AppStyles.cardShadow(context),
        ),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildShimmer(context, radius);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(context, radius);
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: radius,
      ),
      child: const Icon(Icons.image, size: 64, color: Colors.grey),
    );
  }

  Widget _buildShimmer(BuildContext context, BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surfaceVariant,
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            Theme.of(context).colorScheme.surfaceVariant,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
