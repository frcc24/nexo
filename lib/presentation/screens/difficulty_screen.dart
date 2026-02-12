import 'package:flutter/material.dart';

import '../../domain/entities/level.dart';
import '../../domain/services/level_generator.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  static const routeName = '/difficulty';

  @override
  Widget build(BuildContext context) {
    final generator = LevelGenerator();

    return Scaffold(
      body: NexoBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const NexoTitle(),
                const SizedBox(height: 26),
                const Text(
                  'Escolha a dificuldade',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                ...Difficulty.values.map(
                  (difficulty) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DifficultyCard(
                      difficulty: difficulty,
                      onTap: () {
                        final level = generator.generate(
                          worldIndex: 98,
                          levelIndex: difficulty.index + 1,
                          difficulty: difficulty,
                        );
                        Navigator.pushNamed(
                          context,
                          GameScreen.routeName,
                          arguments: GameRouteArgs.quick(level: level),
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Voltar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({required this.difficulty, required this.onTap});

  final Difficulty difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(difficulty.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(difficulty.title),
            const Spacer(),
            Text(
              '${difficulty.size}x${difficulty.size}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
