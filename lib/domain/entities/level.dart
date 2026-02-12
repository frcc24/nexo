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
  });

  final int worldIndex;
  final int levelIndex;
  final int seed;
  final Difficulty difficulty;
  final List<List<CellData>> grid;
  final List<GridPosition> solutionPath;

  int get totalCells => difficulty.size * difficulty.size;

  CellData cellAt(GridPosition position) => grid[position.row][position.col];
}
