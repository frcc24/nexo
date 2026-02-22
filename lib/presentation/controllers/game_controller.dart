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
  List<GridPosition> _activeHint = const [];
  GridPosition? _hintWrongCell;
  GridPosition? _hintExpectedCell;
  bool _hintFeedbackVisible = false;
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
  List<GridPosition> get activeHint => List.unmodifiable(_activeHint);
  bool get hintFeedbackVisible => _hintFeedbackVisible;
  GridPosition? get hintWrongCell =>
      _hintFeedbackVisible ? _hintWrongCell : null;
  GridPosition? get hintExpectedCell =>
      _hintFeedbackVisible ? _hintExpectedCell : null;
  int get correctPrefixLength => _computeCorrectPrefixLength();
  bool get hasRouteError => _path.length > correctPrefixLength;
  GridPosition? get firstWrongCell =>
      hasRouteError ? _path[correctPrefixLength] : null;
  GridPosition? get expectedNextCorrectCell {
    final solution = level.solutionPath;
    if (solution.isEmpty) {
      return null;
    }
    final nextIndex = correctPrefixLength;
    if (nextIndex >= solution.length) {
      return null;
    }
    return solution[nextIndex];
  }

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
      _clearHintFeedback();
      notifyListeners();
      return MoveResult.started;
    }

    if (_path.length > 1 && _path[_path.length - 2] == position) {
      _path.removeLast();
      _clearHintFeedback();
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
    _clearHintFeedback();
    notifyListeners();
    return MoveResult.extended;
  }

  void undo() {
    if (!canUndo) {
      return;
    }
    _usedUndo = true;
    _path.removeLast();
    _clearHintFeedback();
    notifyListeners();
  }

  void restart() {
    if (_path.isEmpty) {
      return;
    }
    _usedRestart = true;
    _path.clear();
    _clearHintFeedback();
    notifyListeners();
  }

  void showHint({int segmentLength = 4}) {
    if (level.solutionPath.isEmpty) {
      _clearHintFeedback();
      notifyListeners();
      return;
    }

    final solution = level.solutionPath;
    final normalizedLength = segmentLength.clamp(2, 8).toInt();
    final prefix = correctPrefixLength;
    int start = prefix > 0 ? prefix - 1 : 0;

    if (start >= solution.length - 1) {
      start = (solution.length - normalizedLength)
          .clamp(0, solution.length - 1)
          .toInt();
    }
    final end = (start + normalizedLength).clamp(0, solution.length).toInt();
    _activeHint = solution.sublist(start, end);
    _hintFeedbackVisible = true;
    _hintWrongCell = hasRouteError ? _path[correctPrefixLength] : null;
    _hintExpectedCell = expectedNextCorrectCell;
    notifyListeners();
  }

  void _clearHintFeedback() {
    _activeHint = const [];
    _hintWrongCell = null;
    _hintExpectedCell = null;
    _hintFeedbackVisible = false;
  }

  int _computeCorrectPrefixLength() {
    final solution = level.solutionPath;
    if (solution.isEmpty || _path.isEmpty) {
      return 0;
    }

    final max = _path.length < solution.length ? _path.length : solution.length;
    for (var i = 0; i < max; i++) {
      if (_path[i] != solution[i]) {
        return i;
      }
    }
    return max;
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
