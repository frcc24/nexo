import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../domain/entities/level.dart';
import '../controllers/world_map_controller.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key, required this.controller});

  static const routeName = '/world-map';

  final WorldMapController controller;

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.init();
    widget.controller.addListener(_onUpdated);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdated);
    super.dispose();
  }

  void _onUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.initialized) {
      return const Scaffold(
        body: NexoBackground(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(context.l10n.t('world_map')),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/difficulty'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: NexoBackground(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          itemCount: WorldMapController.totalWorlds,
          itemBuilder: (context, worldOffset) {
            final l10n = context.l10n;
            final world = worldOffset + 1;
            final difficulty = widget.controller.difficultyForWorld(world);
            final difficultyLabel = switch (difficulty) {
              Difficulty.easy => l10n.t('easy'),
              Difficulty.medium => l10n.t('medium'),
              Difficulty.hard => l10n.t('hard'),
            };

            return Container(
              margin: const EdgeInsets.only(bottom: 26),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.t('world')} $world · $difficultyLabel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(WorldMapController.levelsPerWorld, (
                    levelOffset,
                  ) {
                    final level = levelOffset + 1;
                    final unlocked = widget.controller.isUnlocked(world, level);
                    final stars = widget.controller.starsFor(world, level);
                    final isLeft = level.isEven;

                    return Align(
                      alignment: isLeft
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _LevelNode(
                          level: level,
                          stars: stars,
                          unlocked: unlocked,
                          onTap: unlocked
                              ? () {
                                  final data = widget.controller.buildLevel(
                                    world: world,
                                    level: level,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    GameScreen.routeName,
                                    arguments: GameRouteArgs.progress(
                                      level: data,
                                      worldMapController: widget.controller,
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.level,
    required this.stars,
    required this.unlocked,
    this.onTap,
  });

  final int level;
  final int stars;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: unlocked
              ? const LinearGradient(
                  colors: [AppTheme.brandPurpleLight, AppTheme.brandPurple],
                )
              : const LinearGradient(
                  colors: [Color(0xFF31384A), Color(0xFF31384A)],
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              unlocked ? '$level' : '🔒',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '★' * stars + '☆' * (3 - stars),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
