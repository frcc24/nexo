import 'package:flutter/foundation.dart';

import '../../domain/entities/level.dart';
import '../../domain/entities/position.dart';
import '../../domain/services/game_rules.dart';

enum MoveResult { started, extended, backtracked, ignored, invalid }

class GameController extends ChangeNotifier {
  GameController({
    required this.level,
    GameRules? rules,
    DateTime Function()? now,
  }) : _rules = rules ?? GameRules(),
       _now = now ?? DateTime.now;

  final LevelData level;
  final GameRules _rules;
  final DateTime Function() _now;

  final List<GridPosition> _path = [];
  List<GridPosition> _activeHint = const [];
  GridPosition? _hintWrongCell;
  GridPosition? _hintExpectedCell;
  bool _hintFeedbackVisible = false;
  int _undosUsed = 0;
  int _restartsUsed = 0;
  int _hintsUsed = 0;
  DateTime? _startedAt;
  DateTime? _completedAt;

  List<GridPosition> get path => List.unmodifiable(_path);
  bool get canUndo => _path.length > 1;
  bool get hasStarted => _path.isNotEmpty;
  int get visitedCount => _path.length;
  int get totalCount => level.totalCells;
  bool get isComplete => _path.length == level.totalCells;
  bool get usedUndo => _undosUsed > 0;
  bool get usedRestart => _restartsUsed > 0;
  int get undosUsed => _undosUsed;
  int get restartsUsed => _restartsUsed;
  int get hintsUsed => _hintsUsed;
  Duration get elapsedTime {
    if (_startedAt == null) {
      return Duration.zero;
    }
    final end = _completedAt ?? _now();
    final diff = end.difference(_startedAt!);
    return diff.isNegative ? Duration.zero : diff;
  }

  int get elapsedSeconds => elapsedTime.inSeconds;
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

  int get visitedAnchorsCount {
    if (!level.mechanics.contains(LevelMechanic.anchors)) {
      return 0;
    }
    var count = 0;
    for (final anchor in level.anchors) {
      if (_path.contains(anchor)) {
        count++;
      }
    }
    return count;
  }

  int get totalAnchors => level.anchors.length;

  GridPosition? get nextAnchor {
    if (!level.mechanics.contains(LevelMechanic.anchors)) {
      return null;
    }
    for (final anchor in level.anchors) {
      if (!_path.contains(anchor)) {
        return anchor;
      }
    }
    return null;
  }

  bool isAnchorLocked(GridPosition position) {
    if (!level.mechanics.contains(LevelMechanic.anchors)) {
      return false;
    }
    final idx = level.anchors.indexOf(position);
    if (idx <= 0) {
      return false;
    }
    if (_path.contains(position)) {
      return false;
    }
    for (var i = 0; i < idx; i++) {
      if (!_path.contains(level.anchors[i])) {
        return true;
      }
    }
    return false;
  }

  GridPosition? requiredAnchorBefore(GridPosition position) {
    if (!level.mechanics.contains(LevelMechanic.anchors)) {
      return null;
    }
    final idx = level.anchors.indexOf(position);
    if (idx <= 0) {
      return null;
    }
    for (var i = 0; i < idx; i++) {
      if (!_path.contains(level.anchors[i])) {
        return level.anchors[i];
      }
    }
    return null;
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

  int get baseComplexityScore {
    final cellsScore = level.totalCells * 35;
    final worldScore = level.worldIndex * 120;
    final levelScore = level.levelIndex * 18;
    final anchorsScore = level.mechanics.contains(LevelMechanic.anchors)
        ? 220
        : 0;
    final portalsScore = level.mechanics.contains(LevelMechanic.portals)
        ? 260
        : 0;
    final arrowsScore = level.mechanics.contains(LevelMechanic.arrows)
        ? 240
        : 0;
    return cellsScore +
        worldScore +
        levelScore +
        anchorsScore +
        portalsScore +
        arrowsScore;
  }

  int get expectedSolveSeconds {
    final cellTime = level.totalCells * 5;
    final worldTime = level.worldIndex * 8;
    final levelTime = level.levelIndex * 2;
    final anchorsTime = level.mechanics.contains(LevelMechanic.anchors)
        ? 25
        : 0;
    final portalsTime = level.mechanics.contains(LevelMechanic.portals)
        ? 35
        : 0;
    final arrowsTime = level.mechanics.contains(LevelMechanic.arrows) ? 30 : 0;
    return cellTime +
        worldTime +
        levelTime +
        anchorsTime +
        portalsTime +
        arrowsTime;
  }

  int get score {
    final base = baseComplexityScore;
    final elapsed = elapsedSeconds <= 0 ? 1 : elapsedSeconds;
    final expected = expectedSolveSeconds <= 0 ? 1 : expectedSolveSeconds;
    final efficiency = (expected / elapsed).clamp(0.35, 1.4);
    final timePerformance = (base * 0.45 * efficiency).round();

    final hintPenalty = _hintsUsed * (110 + (level.worldIndex * 12));
    final undoPenalty = _undosUsed * (55 + (level.levelIndex * 2));
    final restartPenalty = _restartsUsed * 180;

    final raw =
        base + timePerformance - hintPenalty - undoPenalty - restartPenalty;
    return raw < 100 ? 100 : raw;
  }

  int get stars {
    final base = baseComplexityScore.toDouble();
    final scoreValue = score;
    final target = base + (base * 0.45);
    final threeStarMin = (target * 0.92).round();
    final twoStarMin = (target * 0.72).round();
    if (scoreValue >= threeStarMin) {
      return 3;
    }
    if (scoreValue >= twoStarMin) {
      return 2;
    }
    return 1;
  }

  MoveResult trySelect(GridPosition position) {
    if (_path.isEmpty) {
      final validStart = _rules.isValidMove(
        level: level,
        path: _path,
        next: position,
      );
      if (!validStart) {
        return MoveResult.invalid;
      }
      _startedAt ??= _now();
      _path.add(position);
      _clearHintFeedback();
      notifyListeners();
      return MoveResult.started;
    }

    if (_path.length > 1 && _path[_path.length - 2] == position) {
      _undosUsed++;
      _path.removeLast();
      _completedAt = null;
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
    if (_path.length == level.totalCells) {
      _completedAt ??= _now();
    }
    _clearHintFeedback();
    notifyListeners();
    return MoveResult.extended;
  }

  void undo() {
    if (!canUndo) {
      return;
    }
    _undosUsed++;
    _path.removeLast();
    _completedAt = null;
    _clearHintFeedback();
    notifyListeners();
  }

  void restart() {
    if (_path.isEmpty) {
      return;
    }
    _restartsUsed++;
    _path.clear();
    _startedAt = null;
    _completedAt = null;
    _clearHintFeedback();
    notifyListeners();
  }

  void showHint({int segmentLength = 4}) {
    if (level.solutionPath.isEmpty) {
      _clearHintFeedback();
      notifyListeners();
      return;
    }
    _hintsUsed++;

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
