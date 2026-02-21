import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/cell_data.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/position.dart';
import '../../domain/services/level_generator.dart';
import '../controllers/game_controller.dart';
import '../controllers/world_map_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/nexo_button.dart';
import '../widgets/unity_game_banner.dart';

class GameRouteArgs {
  const GameRouteArgs._({required this.level, this.worldMapController});

  factory GameRouteArgs.quick({required LevelData level}) =>
      GameRouteArgs._(level: level);

  factory GameRouteArgs.progress({
    required LevelData level,
    required WorldMapController worldMapController,
  }) => GameRouteArgs._(level: level, worldMapController: worldMapController);

  final LevelData level;
  final WorldMapController? worldMapController;

  bool get hasProgression => worldMapController != null;
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.args});

  static const routeName = '/game';

  final GameRouteArgs args;

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
    _controller.dispose();
    _shakeController.dispose();
    _hintPulseController.dispose();
    super.dispose();
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
          title: const Text('Fase concluída!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Estrelas: ${'★' * _controller.stars}${'☆' * (3 - _controller.stars)}',
              ),
              const SizedBox(height: 12),
              Text(
                'Caminho completo: ${_controller.visitedCount}/${_controller.totalCount}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Mapa'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _openNextLevel();
              },
              child: const Text('Próxima fase'),
            ),
          ],
        );
      },
    );
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
    final result = _controller.trySelect(position);
    if (result == MoveResult.invalid) {
      _triggerInvalid();
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = _controller.level;
    final title = 'NEXO · ${level.difficulty.title}';

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(title)),
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
                              hintPulse: _hintPulseController.value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const UnityGameBanner(),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: NexoButton(
                        label: 'Desfazer',
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
                        label: 'Reiniciar',
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
    required this.hintPulse,
  });

  final GameController controller;
  final ValueChanged<GridPosition> onCellTap;
  final Set<GridPosition> hintedCells;
  final double hintPulse;

  @override
  Widget build(BuildContext context) {
    final size = controller.level.difficulty.size;
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
                boardSize: size,
                cellSize: cellSize,
                spacing: spacing,
              ),
            ),
            ...List.generate(size * size, (index) {
              final row = index ~/ size;
              final col = index % size;
              final pos = GridPosition(row, col);
              final cell = controller.level.grid[row][col];
              final selected = controller.path.contains(pos);
              final hinted = hintedCells.contains(pos);
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
                      color: cell.color.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected || hinted
                            ? Colors.white.withValues(
                                alpha: selected ? 0.95 : (0.45 + t * 0.3),
                              )
                            : Colors.transparent,
                        width: selected ? 2.4 : (hinted ? (1.8 + t * 0.6) : 0),
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
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${cell.value}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.97),
                        ),
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
    required this.boardSize,
    required this.cellSize,
    required this.spacing,
  });

  final List<GridPosition> path;
  final int boardSize;
  final double cellSize;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.75);

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
        oldDelegate.boardSize != boardSize ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.spacing != spacing;
  }
}
