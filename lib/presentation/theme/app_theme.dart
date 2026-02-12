import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundTop = Color(0xFF121424);
  static const Color backgroundBottom = Color(0xFF070910);
  static const Color brandPurple = Color(0xFF8B44FF);
  static const Color brandPurpleLight = Color(0xFFAF67FF);
  static const Color surface = Color(0xFF1B1F31);
  static const Color surfaceSoft = Color(0xFF20263B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA7ADC0);

  static ThemeData buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPurple,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class NexoBackground extends StatelessWidget {
  const NexoBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
        ),
      ),
      child: child,
    );
  }
}

class NexoTitle extends StatelessWidget {
  const NexoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [AppTheme.brandPurpleLight, AppTheme.brandPurple],
        ).createShader(bounds);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NEXO',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: Colors.white, height: 1),
          ),
          const SizedBox(height: 8),
          Text(
            'CONEXÕES LÓGICAS',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
