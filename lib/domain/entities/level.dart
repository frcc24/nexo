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

  int get totalCells => difficulty.size * difficulty.size;

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
}

enum LevelMechanic { anchors, portals }

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
