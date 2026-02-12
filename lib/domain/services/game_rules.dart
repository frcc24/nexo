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
      return true;
    }

    final last = path.last;
    if (!last.isOrthogonallyAdjacent(next)) {
      return false;
    }

    if (path.contains(next)) {
      return false;
    }

    final fromCell = level.cellAt(last);
    final toCell = level.cellAt(next);
    return isValidTransition(fromCell, toCell);
  }
}
