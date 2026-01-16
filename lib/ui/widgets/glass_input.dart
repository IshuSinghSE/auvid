import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// A glassmorphism-style text input field
class GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Function(String)? onSubmitted;
  final TextInputType? keyboardType;

  const GlassInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon = Icons.link,
    this.onSubmitted,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppStyles.borderRadiusMedium,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: AppStyles.borderRadiusMedium,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingMedium,
          ),
        ),
        style: const TextStyle(fontSize: 16),
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
