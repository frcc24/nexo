import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/cell_data.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/position.dart';
import '../../domain/services/level_generator.dart';
import '../../localization/app_localizations.dart';
import '../controllers/game_controller.dart';
import '../controllers/purchase_controller.dart';
import '../controllers/retention_controller.dart';
import '../controllers/world_map_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/nexo_button.dart';
import '../widgets/rule_modal.dart';
import '../widgets/unity_game_banner.dart';

class GameRouteArgs {
  const GameRouteArgs._({
    required this.level,
    this.worldMapController,
    this.isDailyChallenge = false,
  });

  factory GameRouteArgs.quick({required LevelData level}) =>
      GameRouteArgs._(level: level);

  factory GameRouteArgs.progress({
    required LevelData level,
    required WorldMapController worldMapController,
  }) => GameRouteArgs._(level: level, worldMapController: worldMapController);

  factory GameRouteArgs.dailyChallenge({required LevelData level}) =>
      GameRouteArgs._(level: level, isDailyChallenge: true);

  final LevelData level;
  final WorldMapController? worldMapController;
  final bool isDailyChallenge;

  bool get hasProgression => worldMapController != null;
}

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.args,
    required this.purchaseController,
    required this.retentionController,
  });

  static const routeName = '/game';

  final GameRouteArgs args;
  final PurchaseController purchaseController;
  final RetentionController retentionController;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _controller;
  late AnimationController _shakeController;
  late AnimationController _hintPulseController;
  bool _completionShown = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController(level: widget.args.level);
    _controller.addListener(_onGameUpdated);
    widget.purchaseController.addListener(_onPurchaseChanged);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _hintPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameUpdated);
    widget.purchaseController.removeListener(_onPurchaseChanged);
    _controller.dispose();
    _shakeController.dispose();
    _hintPulseController.dispose();
    super.dispose();
  }

  void _onPurchaseChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onGameUpdated() {
    if (mounted) {
      setState(() {});
    }

    if (_controller.isComplete && !_completionShown) {
      _completionShown = true;
      _handleWin();
    }
  }

  Future<void> _handleWin() async {
    final l10n = context.l10n;
    final newAchievements = await widget.retentionController
        .recordLevelCompleted(
          level: _controller.level,
          stars: _controller.stars,
          score: _controller.score,
          hintsUsed: _controller.hintsUsed,
          isDailyChallenge: widget.args.isDailyChallenge,
        );
    final earnedCoins = widget.retentionController.lastCoinsEarned;
    if (widget.args.hasProgression) {
      await widget.args.worldMapController!.completeLevel(
        level: _controller.level,
        stars: _controller.stars,
      );
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(l10n.t('stage_done')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l10n.t('stars')}: ${'★' * _controller.stars}${'☆' * (3 - _controller.stars)}',
              ),
              const SizedBox(height: 8),
              Text('${l10n.t('score')}: ${_controller.score}'),
              const SizedBox(height: 6),
              Text(
                '${l10n.t('time')}: ${_formatDuration(_controller.elapsedTime)}',
              ),
              const SizedBox(height: 6),
              Text(
                '${l10n.t('hints_used')}: ${_controller.hintsUsed} · '
                '${l10n.t('undos_used')}: ${_controller.undosUsed} · '
                '${l10n.t('restarts_used')}: ${_controller.restartsUsed}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${l10n.t('path_complete')}: ${_controller.visitedCount}/${_controller.totalCount}',
              ),
              if (newAchievements > 0) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.newAchievementsUnlocked(newAchievements),
                  style: const TextStyle(color: Color(0xFFF6D04D)),
                  textAlign: TextAlign.center,
                ),
              ],
              if (earnedCoins > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '+$earnedCoins ${l10n.t('coins')}',
                  style: const TextStyle(color: Color(0xFFFFD54F)),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                widget.args.isDailyChallenge ? l10n.t('home') : l10n.t('map'),
              ),
            ),
            if (!widget.args.isDailyChallenge)
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openNextLevel();
                },
                child: Text(l10n.t('next_level')),
              ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _openNextLevel() {
    if (!widget.args.hasProgression) {
      final next = LevelGenerator().generate(
        worldIndex: _controller.level.worldIndex,
        levelIndex: _controller.level.levelIndex + 1,
        difficulty: _controller.level.difficulty,
      );
      Navigator.pushReplacementNamed(
        context,
        GameScreen.routeName,
        arguments: GameRouteArgs.quick(level: next),
      );
      return;
    }

    final current = _controller.level;
    int nextWorld = current.worldIndex;
    int nextLevel = current.levelIndex + 1;
    if (nextLevel > WorldMapController.levelsPerWorld) {
      nextWorld += 1;
      nextLevel = 1;
    }
    if (nextWorld > WorldMapController.totalWorlds) {
      Navigator.pop(context);
      return;
    }

    final controller = widget.args.worldMapController!;
    if (!controller.isUnlocked(nextWorld, nextLevel)) {
      Navigator.pop(context);
      return;
    }

    final level = controller.buildLevel(world: nextWorld, level: nextLevel);
    Navigator.pushReplacementNamed(
      context,
      GameScreen.routeName,
      arguments: GameRouteArgs.progress(
        level: level,
        worldMapController: controller,
      ),
    );
  }

  void _triggerInvalid() {
    _shakeController.forward(from: 0);
    HapticFeedback.lightImpact();
  }

  void _handleCellTap(GridPosition position) {
    if (_controller.isAnchorLocked(position)) {
      final l10n = context.l10n;
      final requiredAnchor = _controller.requiredAnchorBefore(position);
      final currentOrder = _controller.level.anchorOrderAt(position);
      final requiredOrder = requiredAnchor == null
          ? null
          : _controller.level.anchorOrderAt(requiredAnchor);
      if (requiredOrder != null && currentOrder != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.anchorLockedMessage(
                requiredAnchor: 'A$requiredOrder',
                currentAnchor: 'A$currentOrder',
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _triggerInvalid();
      return;
    }

    final result = _controller.trySelect(position);
    if (result == MoveResult.invalid) {
      _triggerInvalid();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final level = _controller.level;
    final difficultyLabel = switch (level.difficulty) {
      Difficulty.easy => l10n.t('easy'),
      Difficulty.medium => l10n.t('medium'),
      Difficulty.hard => l10n.t('hard'),
    };
    final title = '${l10n.t('app_title')} · $difficultyLabel';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => showRulesModal(context, level: level),
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: NexoBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${_controller.visitedCount}/${_controller.totalCount}',
                    ),
                    const Spacer(),
                    Text('${(_controller.progress * 100).toStringAsFixed(0)}%'),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _controller.progress,
                    minHeight: 10,
                    backgroundColor: AppTheme.surfaceSoft,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.brandPurpleLight,
                    ),
                  ),
                ),
                if (level.mechanics.contains(LevelMechanic.anchors))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: Color(0xFF53F0CC),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${l10n.t('anchor_progress')}: ${_controller.visitedAnchorsCount}/${_controller.totalAnchors}',
                          style: const TextStyle(
                            color: Color(0xFFB9F8EA),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_controller.hintFeedbackVisible &&
                    _controller.hintExpectedCell != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Color(0xFFFF7C82),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${l10n.t('route_error_title')} '
                            '${l10n.routeErrorNext(row: _controller.hintExpectedCell!.row + 1, col: _controller.hintExpectedCell!.col + 1)}',
                            style: const TextStyle(
                              color: Color(0xFFFFB2B6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boardSize = min(
                          constraints.maxWidth,
                          constraints.maxHeight - 16,
                        );
                        return AnimatedBuilder(
                          animation: Listenable.merge([
                            _shakeController,
                            _hintPulseController,
                          ]),
                          builder: (context, child) {
                            final offsetX =
                                sin(_shakeController.value * pi * 8) *
                                7 *
                                (1 - _shakeController.value);
                            return Transform.translate(
                              offset: Offset(offsetX, 0),
                              child: child,
                            );
                          },
                          child: SizedBox(
                            width: boardSize,
                            height: boardSize,
                            child: _Board(
                              controller: _controller,
                              onCellTap: _handleCellTap,
                              hintedCells: _controller.nextHints,
                              hintPath: _controller.activeHint,
                              wrongCell: _controller.hintWrongCell,
                              expectedCell: _controller.hintExpectedCell,
                              hintPulse: _hintPulseController.value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (!widget.purchaseController.hasRemovedAds)
                  const UnityGameBanner(),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: NexoButton(
                        label: l10n.t('hint'),
                        icon: Icons.lightbulb_outline,
                        primary: true,
                        onPressed: _controller.isComplete
                            ? null
                            : () {
                                _controller.showHint();
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NexoButton(
                        label: l10n.t('undo'),
                        icon: Icons.undo,
                        primary: false,
                        onPressed: _controller.canUndo
                            ? _controller.undo
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NexoButton(
                        label: l10n.t('restart'),
                        icon: Icons.refresh,
                        primary: false,
                        onPressed: _controller.hasStarted
                            ? _controller.restart
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({
    required this.controller,
    required this.onCellTap,
    required this.hintedCells,
    required this.hintPath,
    required this.wrongCell,
    required this.expectedCell,
    required this.hintPulse,
  });

  final GameController controller;
  final ValueChanged<GridPosition> onCellTap;
  final Set<GridPosition> hintedCells;
  final List<GridPosition> hintPath;
  final GridPosition? wrongCell;
  final GridPosition? expectedCell;
  final double hintPulse;

  @override
  Widget build(BuildContext context) {
    final size = controller.level.gridSize;
    const spacing = 6.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - ((size - 1) * spacing)) / size;

        return Stack(
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _PathPainter(
                path: controller.path,
                cellSize: cellSize,
                spacing: spacing,
                color: Colors.white.withValues(alpha: 0.78),
                strokeWidth: 6,
              ),
            ),
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _PathPainter(
                path: hintPath,
                cellSize: cellSize,
                spacing: spacing,
                color: const Color(0xFF53F0CC).withValues(alpha: 0.75),
                strokeWidth: 4,
              ),
            ),
            ...List.generate(size * size, (index) {
              final row = index ~/ size;
              final col = index % size;
              final pos = GridPosition(row, col);
              final cell = controller.level.grid[row][col];
              final selected = controller.path.contains(pos);
              final hinted = hintedCells.contains(pos);
              final inHintPath = hintPath.contains(pos);
              final isWrong = wrongCell == pos;
              final isExpected = expectedCell == pos;
              final anchorOrder = controller.level.anchorOrderAt(pos);
              final isLockedAnchor = controller.isAnchorLocked(pos);
              final portalPair = controller.level.portalPairAt(pos);
              final forcedDirection = controller.level.forcedDirectionAt(pos);
              final t = Curves.easeInOut.transform(hintPulse);
              final hintAlpha = 0.14 + (0.2 * t);

              return Positioned(
                left: col * (cellSize + spacing),
                top: row * (cellSize + spacing),
                width: cellSize,
                height: cellSize,
                child: GestureDetector(
                  onTap: () => onCellTap(pos),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: isLockedAnchor
                          ? Color.alphaBlend(Colors.black54, cell.color.color)
                          : cell.color.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isWrong
                            ? const Color(0xFFFF656B)
                            : isExpected
                            ? const Color(
                                0xFF53F0CC,
                              ).withValues(alpha: 0.75 + (0.2 * t))
                            : selected || hinted
                            ? Colors.white.withValues(
                                alpha: selected ? 0.95 : (0.45 + t * 0.3),
                              )
                            : inHintPath
                            ? const Color(
                                0xFF53F0CC,
                              ).withValues(alpha: 0.58 + (0.3 * t))
                            : Colors.transparent,
                        width: isWrong
                            ? 2.6
                            : isExpected
                            ? (2 + t * 0.6)
                            : selected
                            ? 2.4
                            : hinted
                            ? (1.8 + t * 0.6)
                            : inHintPath
                            ? (1.6 + t * 0.5)
                            : 0,
                      ),
                      boxShadow: [
                        if (selected)
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        if (hinted)
                          BoxShadow(
                            color: Colors.white.withValues(alpha: hintAlpha),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        if (inHintPath)
                          BoxShadow(
                            color: const Color(
                              0xFF53F0CC,
                            ).withValues(alpha: 0.2 + (0.2 * t)),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        if (isWrong)
                          BoxShadow(
                            color: const Color(
                              0xFFFF656B,
                            ).withValues(alpha: 0.35),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        if (isExpected)
                          BoxShadow(
                            color: const Color(
                              0xFF53F0CC,
                            ).withValues(alpha: 0.22 + (0.25 * t)),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        if (isLockedAnchor)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '${cell.value}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.97),
                              ),
                            ),
                          ),
                          if (anchorOrder != null)
                            Positioned(
                              top: 4,
                              right: 6,
                              child: Text(
                                'A$anchorOrder',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (portalPair != null)
                            Positioned(
                              left: 6,
                              bottom: 4,
                              child: Text(
                                'P${portalPair.id}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (forcedDirection != null)
                            Positioned(
                              right: 6,
                              bottom: 4,
                              child: Text(
                                forcedDirection.symbol,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (isLockedAnchor)
                            const Positioned(
                              left: 6,
                              top: 4,
                              child: Icon(
                                Icons.lock_outline,
                                size: 12,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _PathPainter extends CustomPainter {
  const _PathPainter({
    required this.path,
    required this.cellSize,
    required this.spacing,
    required this.color,
    required this.strokeWidth,
  });

  final List<GridPosition> path;
  final double cellSize;
  final double spacing;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    for (var i = 0; i < path.length - 1; i++) {
      final from = _center(path[i]);
      final to = _center(path[i + 1]);
      canvas.drawLine(from, to, paint);
    }
  }

  Offset _center(GridPosition p) {
    final x = p.col * (cellSize + spacing) + (cellSize / 2);
    final y = p.row * (cellSize + spacing) + (cellSize / 2);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.spacing != spacing ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
