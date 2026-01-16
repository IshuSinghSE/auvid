  import 'package:flutter/material.dart';
  import '../../core/theme.dart';

  class AppSwitchTile extends StatelessWidget {
    final IconData icon;
    final String title;
    final String subtitle;
    final bool value;
    final Color? activeColor;
    final ValueChanged<bool> onChanged;

    const AppSwitchTile({
      Key? key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.value,
      this.activeColor,
      required this.onChanged,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      final Color color = activeColor ?? AppTheme.primary;

      return SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        activeColor: color,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: value ? color : Colors.grey, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        value: value,
        onChanged: onChanged,
      );
    }
  }