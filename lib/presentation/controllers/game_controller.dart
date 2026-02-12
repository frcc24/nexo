import 'package:flutter/foundation.dart';

import '../../domain/entities/level.dart';
import '../../domain/entities/position.dart';
import '../../domain/services/game_rules.dart';

enum MoveResult { started, extended, backtracked, ignored, invalid }

class GameController extends ChangeNotifier {
  GameController({required this.level, GameRules? rules})
    : _rules = rules ?? GameRules();

  final LevelData level;
  final GameRules _rules;

  final List<GridPosition> _path = [];
  bool _usedUndo = false;
  bool _usedRestart = false;

  List<GridPosition> get path => List.unmodifiable(_path);
  bool get canUndo => _path.length > 1;
  bool get hasStarted => _path.isNotEmpty;
  int get visitedCount => _path.length;
  int get totalCount => level.totalCells;
  bool get isComplete => _path.length == level.totalCells;
  bool get usedUndo => _usedUndo;
  bool get usedRestart => _usedRestart;
  double get progress => _path.isEmpty ? 0 : _path.length / level.totalCells;
  Set<GridPosition> get nextHints {
    if (_path.isEmpty) {
      return <GridPosition>{};
    }

    final hints = <GridPosition>{};
    final last = _path.last;
    for (final neighbor in _neighbors(last)) {
      if (_path.contains(neighbor)) {
        continue;
      }
      final valid = _rules.isValidMove(
        level: level,
        path: _path,
        next: neighbor,
      );
      if (valid) {
        hints.add(neighbor);
      }
    }

    if (_path.length > 1) {
      hints.add(_path[_path.length - 2]);
    }

    return hints;
  }

  int get stars {
    if (_usedRestart) {
      return 1;
    }
    if (_usedUndo) {
      return 2;
    }
    return 3;
  }

  MoveResult trySelect(GridPosition position) {
    if (_path.isEmpty) {
      _path.add(position);
      notifyListeners();
      return MoveResult.started;
    }

    if (_path.length > 1 && _path[_path.length - 2] == position) {
      _path.removeLast();
      notifyListeners();
      return MoveResult.backtracked;
    }

    if (_path.contains(position)) {
      return MoveResult.ignored;
    }

    final valid = _rules.isValidMove(level: level, path: _path, next: position);
    if (!valid) {
      return MoveResult.invalid;
    }

    _path.add(position);
    notifyListeners();
    return MoveResult.extended;
  }

  void undo() {
    if (!canUndo) {
      return;
    }
    _usedUndo = true;
    _path.removeLast();
    notifyListeners();
  }

  void restart() {
    if (_path.isEmpty) {
      return;
    }
    _usedRestart = true;
    _path.clear();
    notifyListeners();
  }

  Iterable<GridPosition> _neighbors(GridPosition position) {
    const deltas = [
      GridPosition(-1, 0),
      GridPosition(1, 0),
      GridPosition(0, -1),
      GridPosition(0, 1),
    ];

    return deltas
        .map(
          (delta) =>
              GridPosition(position.row + delta.row, position.col + delta.col),
        )
        .where(
          (p) =>
              p.row >= 0 &&
              p.col >= 0 &&
              p.row < level.difficulty.size &&
              p.col < level.difficulty.size,
        );
  }
}
