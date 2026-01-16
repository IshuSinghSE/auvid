import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// A styled action button with loading state support
class ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  final double? width;
  final double height;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
    this.width,
    this.height = AppConstants.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild;
    
    if (isLoading) {
      buttonChild = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: AppConstants.spacingSmall),
          Text(label, style: AppStyles.buttonTextStyle),
        ],
      );
    } else {
      buttonChild = Text(label, style: AppStyles.buttonTextStyle);
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isPrimary
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppStyles.borderRadiusMedium,
                ),
                elevation: 0,
              ),
              onPressed: isLoading ? null : onPressed,
              child: buttonChild,
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: AppStyles.borderRadiusMedium,
                ),
              ),
              onPressed: isLoading ? null : onPressed,
              child: buttonChild,
            ),
    );
  }
}
