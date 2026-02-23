import '../entities/cell_data.dart';
import '../entities/level.dart';
import '../entities/position.dart';

class GameRules {
  bool isValidTransition(CellData from, CellData to) {
    if (from.color == to.color) {
      return (from.value - to.value).abs() == 1;
    }
    return from.value == to.value;
  }

  bool isValidMove({
    required LevelData level,
    required List<GridPosition> path,
    required GridPosition next,
  }) {
    if (path.isEmpty) {
      if (!_respectsAnchorOrder(level: level, path: path, next: next)) {
        return false;
      }
      return true;
    }

    final last = path.last;
    final isPortalJump = _isPortalJump(level: level, from: last, to: next);
    if (!last.isOrthogonallyAdjacent(next) && !isPortalJump) {
      return false;
    }

    if (path.contains(next)) {
      return false;
    }

    if (!_respectsAnchorOrder(level: level, path: path, next: next)) {
      return false;
    }

    final fromCell = level.cellAt(last);
    final toCell = level.cellAt(next);
    return isValidTransition(fromCell, toCell);
  }

  bool _isPortalJump({
    required LevelData level,
    required GridPosition from,
    required GridPosition to,
  }) {
    if (!level.mechanics.contains(LevelMechanic.portals)) {
      return false;
    }
    final pair = level.portalPairAt(from);
    if (pair == null) {
      return false;
    }
    return pair.other(from) == to;
  }

  bool _respectsAnchorOrder({
    required LevelData level,
    required List<GridPosition> path,
    required GridPosition next,
  }) {
    if (!level.mechanics.contains(LevelMechanic.anchors) ||
        level.anchors.isEmpty) {
      return true;
    }
    final nextAnchorIndex = level.anchors.indexOf(next);
    if (nextAnchorIndex <= 0) {
      return true;
    }
    for (var i = 0; i < nextAnchorIndex; i++) {
      if (!path.contains(level.anchors[i])) {
        return false;
      }
    }
    return true;
  }
}
