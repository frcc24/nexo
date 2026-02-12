import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NexoButton extends StatelessWidget {
  const NexoButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.primary = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final bg = primary
        ? const LinearGradient(
            colors: [AppTheme.brandPurpleLight, AppTheme.brandPurple],
          )
        : const LinearGradient(
            colors: [AppTheme.surfaceSoft, AppTheme.surfaceSoft],
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white54,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
