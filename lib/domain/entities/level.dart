import 'cell_data.dart';
import 'position.dart';

enum Difficulty {
  easy(size: 4, title: 'Fácil', icon: '⚡'),
  medium(size: 5, title: 'Médio', icon: '🧠'),
  hard(size: 6, title: 'Difícil', icon: '🔥');

  const Difficulty({
    required this.size,
    required this.title,
    required this.icon,
  });

  final int size;
  final String title;
  final String icon;
}

class LevelData {
  const LevelData({
    required this.worldIndex,
    required this.levelIndex,
    required this.seed,
    required this.difficulty,
    required this.grid,
    required this.solutionPath,
    this.mechanics = const <LevelMechanic>{},
    this.anchors = const <GridPosition>[],
    this.portalPairs = const <PortalPair>[],
    this.forcedDirections = const <GridPosition, MoveDirection>{},
    this.gridSizeOverride,
  });

  final int worldIndex;
  final int levelIndex;
  final int seed;
  final Difficulty difficulty;
  final List<List<CellData>> grid;
  final List<GridPosition> solutionPath;
  final Set<LevelMechanic> mechanics;
  final List<GridPosition> anchors;
  final List<PortalPair> portalPairs;
  final Map<GridPosition, MoveDirection> forcedDirections;
  final int? gridSizeOverride;

  int get gridSize => gridSizeOverride ?? difficulty.size;

  int get totalCells => gridSize * gridSize;

  CellData cellAt(GridPosition position) => grid[position.row][position.col];

  int? anchorOrderAt(GridPosition position) {
    final idx = anchors.indexOf(position);
    return idx >= 0 ? idx + 1 : null;
  }

  PortalPair? portalPairAt(GridPosition position) {
    for (final pair in portalPairs) {
      if (pair.a == position || pair.b == position) {
        return pair;
      }
    }
    return null;
  }

  MoveDirection? forcedDirectionAt(GridPosition position) {
    return forcedDirections[position];
  }
}

enum LevelMechanic { anchors, portals, arrows }

enum MoveDirection {
  up(deltaRow: -1, deltaCol: 0, symbol: '↑'),
  down(deltaRow: 1, deltaCol: 0, symbol: '↓'),
  left(deltaRow: 0, deltaCol: -1, symbol: '←'),
  right(deltaRow: 0, deltaCol: 1, symbol: '→');

  const MoveDirection({
    required this.deltaRow,
    required this.deltaCol,
    required this.symbol,
  });

  final int deltaRow;
  final int deltaCol;
  final String symbol;

  GridPosition moveFrom(GridPosition position) {
    return GridPosition(position.row + deltaRow, position.col + deltaCol);
  }

  static MoveDirection fromStep({
    required GridPosition from,
    required GridPosition to,
  }) {
    final rowDelta = to.row - from.row;
    final colDelta = to.col - from.col;
    if (rowDelta == -1 && colDelta == 0) {
      return MoveDirection.up;
    }
    if (rowDelta == 1 && colDelta == 0) {
      return MoveDirection.down;
    }
    if (rowDelta == 0 && colDelta == -1) {
      return MoveDirection.left;
    }
    return MoveDirection.right;
  }
}

class PortalPair {
  const PortalPair({required this.id, required this.a, required this.b});

  final int id;
  final GridPosition a;
  final GridPosition b;

  bool contains(GridPosition position) => position == a || position == b;

  GridPosition other(GridPosition position) {
    if (position == a) {
      return b;
    }
    return a;
  }
}
