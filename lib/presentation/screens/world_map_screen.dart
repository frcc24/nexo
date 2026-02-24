import 'package:flutter/material.dart';

import '../../data/services/unity_ads_service.dart';
import '../../domain/entities/level.dart';
import '../../localization/app_localizations.dart';
import '../controllers/retention_controller.dart';
import '../controllers/world_map_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/rule_modal.dart';
import 'game_screen.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({
    super.key,
    required this.controller,
    required this.retentionController,
  });

  static const routeName = '/world-map';

  final WorldMapController controller;
  final RetentionController retentionController;

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _levelKeys = {};

  final Set<int> _expandedWorlds = <int>{};
  bool _expansionInitialized = false;
  bool _autoScrolledToNext = false;
  bool _unlockingByAd = false;

  @override
  void initState() {
    super.initState();
    widget.controller.init();
    widget.controller.addListener(_onUpdated);
    widget.retentionController.addListener(_onUpdated);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdated);
    widget.retentionController.removeListener(_onUpdated);
    _scrollController.dispose();
    super.dispose();
  }

  void _onUpdated() {
    if (!mounted) return;
    setState(() {});
    _scheduleAutoScrollToNext();
  }

  bool _isWorldCompleted(int world) {
    for (var level = 1; level <= WorldMapController.levelsPerWorld; level++) {
      if (!widget.controller.isCompleted(world, level)) {
        return false;
      }
    }
    return true;
  }

  bool _isWorldUnlocked(int world) {
    return widget.controller.isUnlocked(world, 1);
  }

  (int world, int level)? _nextPlayableLevel() {
    for (var world = 1; world <= WorldMapController.totalWorlds; world++) {
      for (var level = 1; level <= WorldMapController.levelsPerWorld; level++) {
        if (!widget.controller.isUnlocked(world, level)) {
          continue;
        }
        if (!widget.controller.isCompleted(world, level)) {
          return (world, level);
        }
      }
    }
    return null;
  }

  void _initializeExpansionState() {
    if (_expansionInitialized) {
      return;
    }

    final next = _nextPlayableLevel();
    for (var world = 1; world <= WorldMapController.totalWorlds; world++) {
      final unlocked = _isWorldUnlocked(world);
      final completed = _isWorldCompleted(world);
      final containsNext = next != null && next.$1 == world;
      if (unlocked && (!completed || containsNext)) {
        _expandedWorlds.add(world);
      }
    }

    _expansionInitialized = true;
  }

  String _levelKeyId(int world, int level) => '${world}_$level';

  GlobalKey _levelKey(int world, int level) {
    final id = _levelKeyId(world, level);
    return _levelKeys.putIfAbsent(id, () => GlobalKey());
  }

  void _scheduleAutoScrollToNext() {
    if (_autoScrolledToNext || !widget.controller.initialized || !mounted) {
      return;
    }

    final next = _nextPlayableLevel();
    if (next == null) {
      return;
    }

    _expandedWorlds.add(next.$1);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final key = _levelKeys[_levelKeyId(next.$1, next.$2)];
      final levelContext = key?.currentContext;
      if (levelContext == null) {
        return;
      }

      await Scrollable.ensureVisible(
        levelContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
      _autoScrolledToNext = true;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _openLevel({required int world, required int level}) async {
    final data = widget.controller.buildLevel(world: world, level: level);
    final shouldShowIntro =
        data.mechanics.isNotEmpty &&
        await widget.controller.shouldShowWorldRuleIntro(world);

    if (mounted && shouldShowIntro) {
      await showRulesModal(
        context,
        level: data,
        customTitle:
            '${context.l10n.t('world')} $world · ${context.l10n.t('new_rules')}',
      );
      await widget.controller.markWorldRuleIntroSeen(world);
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      GameScreen.routeName,
      arguments: GameRouteArgs.progress(
        level: data,
        worldMapController: widget.controller,
      ),
    );
  }

  Future<void> _handleLockedLevelTap({
    required int world,
    required int level,
  }) async {
    final l10n = context.l10n;
    final canUnlock = widget.controller.canUnlockWithReward(world, level);
    if (!canUnlock) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t('locked_level_hint'))));
      return;
    }

    if (_unlockingByAd) {
      return;
    }

    final cost = widget.retentionController.coinCostForLevel(
      world: world,
      level: level,
    );
    final hasCoins = widget.retentionController.coins >= cost;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(l10n.t('unlock_level_title')),
        content: Text(
          '${l10n.unlockWithAdMessage(level)}\n\n'
          '${l10n.t('unlock_with_coins')}: $cost (${l10n.t('coins')}: ${widget.retentionController.coins})',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text(l10n.t('back')),
          ),
          FilledButton.icon(
            onPressed: hasCoins ? () => Navigator.pop(context, 'coins') : null,
            icon: const Icon(Icons.monetization_on_outlined),
            label: Text(l10n.t('unlock_with_coins')),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, 'ad'),
            icon: const Icon(Icons.ondemand_video),
            label: Text(l10n.t('watch_ad_unlock')),
          ),
        ],
      ),
    );

    if (!mounted || choice == null || choice == 'cancel') {
      return;
    }

    if (choice == 'coins') {
      final paid = await widget.retentionController.spendCoins(cost);
      if (!paid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.t('not_enough_coins'))));
        return;
      }
      final unlocked = await widget.controller.unlockWithReward(world, level);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unlocked ? l10n.unlockSuccess(level) : l10n.t('reward_ad_failed'),
          ),
        ),
      );
      return;
    }

    setState(() {
      _unlockingByAd = true;
    });
    final rewarded = await UnityAdsService.showRewardedUnlockAd();
    if (!mounted) {
      return;
    }

    setState(() {
      _unlockingByAd = false;
    });

    if (!rewarded) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t('reward_ad_failed'))));
      return;
    }

    final unlocked = await widget.controller.unlockWithReward(world, level);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          unlocked ? l10n.unlockSuccess(level) : l10n.t('reward_ad_failed'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.initialized) {
      return const Scaffold(
        body: NexoBackground(child: Center(child: CircularProgressIndicator())),
      );
    }

    _initializeExpansionState();
    _scheduleAutoScrollToNext();

    final nextPlayable = _nextPlayableLevel();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(context.l10n.t('world_map')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSoft.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 16,
                      color: Color(0xFFFFD54F),
                    ),
                    const SizedBox(width: 4),
                    Text('${widget.retentionController.coins}'),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/difficulty'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: NexoBackground(
        child: ListView.builder(
          controller: _scrollController,
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
            final worldUnlocked = _isWorldUnlocked(world);
            final worldCompleted = _isWorldCompleted(world);

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: PageStorageKey('world_$world'),
                  enabled: worldUnlocked,
                  initiallyExpanded:
                      worldUnlocked && _expandedWorlds.contains(world),
                  onExpansionChanged: (expanded) {
                    if (!worldUnlocked) {
                      return;
                    }
                    setState(() {
                      if (expanded) {
                        _expandedWorlds.add(world);
                      } else {
                        _expandedWorlds.remove(world);
                      }
                    });
                  },
                  title: Text(
                    '${l10n.t('world')} $world · $difficultyLabel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: worldCompleted
                      ? Text(
                          l10n.t('world_completed'),
                          style: const TextStyle(color: AppTheme.textSecondary),
                        )
                      : !worldUnlocked
                      ? const Text(
                          '🔒',
                          style: TextStyle(color: AppTheme.textSecondary),
                        )
                      : null,
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  children: [
                    ...List.generate(WorldMapController.levelsPerWorld, (
                      levelOffset,
                    ) {
                      final level = levelOffset + 1;
                      final unlocked = widget.controller.isUnlocked(
                        world,
                        level,
                      );
                      final stars = widget.controller.starsFor(world, level);
                      final rewardUnlockAvailable = widget.controller
                          .canUnlockWithReward(world, level);
                      final isLeft = level.isEven;
                      final isNextTarget =
                          nextPlayable != null &&
                          nextPlayable.$1 == world &&
                          nextPlayable.$2 == level;

                      return Align(
                        key: _levelKey(world, level),
                        alignment: isLeft
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: _LevelNode(
                            level: level,
                            stars: stars,
                            unlocked: unlocked,
                            rewardUnlockAvailable: rewardUnlockAvailable,
                            isNextTarget: isNextTarget,
                            onTap: unlocked
                                ? () => _openLevel(world: world, level: level)
                                : () => _handleLockedLevelTap(
                                    world: world,
                                    level: level,
                                  ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
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
    required this.rewardUnlockAvailable,
    required this.isNextTarget,
    this.onTap,
  });

  final int level;
  final int stars;
  final bool unlocked;
  final bool rewardUnlockAvailable;
  final bool isNextTarget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gradient = isNextTarget
        ? const LinearGradient(colors: [Color(0xFFF6D04D), Color(0xFFE9B722)])
        : unlocked
        ? const LinearGradient(
            colors: [AppTheme.brandPurpleLight, AppTheme.brandPurple],
          )
        : const LinearGradient(colors: [Color(0xFF31384A), Color(0xFF31384A)]);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 178,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: gradient,
          border: isNextTarget
              ? Border.all(color: const Color(0xFFFFEE9B), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: isNextTarget
                  ? const Color(0xFFE9B722).withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.3),
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
            if (!unlocked && rewardUnlockAvailable) ...[
              const SizedBox(width: 8),
              const Icon(Icons.ondemand_video, size: 16, color: Colors.white70),
            ],
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
