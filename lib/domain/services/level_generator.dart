import 'dart:math';

import '../entities/cell_data.dart';
import '../entities/level.dart';
import '../entities/position.dart';
import 'game_rules.dart';

class LevelGenerator {
  LevelGenerator({GameRules? rules}) : _rules = rules ?? GameRules();

  final GameRules _rules;

  LevelData generate({
    required int worldIndex,
    required int levelIndex,
    required Difficulty difficulty,
  }) {
    final seed = worldIndex * 100000 + levelIndex;
    final random = Random(seed);
    final size = difficulty.size;

    final path = _buildHamiltonianPath(size: size, random: random);
    final grid = _assignCells(
      path: path,
      difficulty: difficulty,
      random: random,
    );

    return LevelData(
      worldIndex: worldIndex,
      levelIndex: levelIndex,
      seed: seed,
      difficulty: difficulty,
      grid: grid,
      solutionPath: path,
    );
  }

  List<GridPosition> _buildHamiltonianPath({
    required int size,
    required Random random,
  }) {
    final allPositions = List<GridPosition>.generate(
      size * size,
      (index) => GridPosition(index ~/ size, index % size),
    );

    final total = size * size;
    for (var attempt = 0; attempt < 200; attempt++) {
      final start = allPositions[random.nextInt(allPositions.length)];
      final path = <GridPosition>[start];
      final visited = <GridPosition>{start};

      if (_searchPath(size, total, path, visited, random)) {
        return path;
      }
    }

    throw StateError('Nao foi possivel gerar caminho para $size x $size');
  }

  bool _searchPath(
    int size,
    int total,
    List<GridPosition> path,
    Set<GridPosition> visited,
    Random random,
  ) {
    if (path.length == total) {
      return true;
    }

    final current = path.last;
    final candidates = _neighbors(
      current,
      size,
    ).where((position) => !visited.contains(position)).toList();

    candidates.sort((a, b) {
      final degreeA = _availableDegree(a, size, visited);
      final degreeB = _availableDegree(b, size, visited);
      if (degreeA == degreeB) {
        return random.nextInt(3) - 1;
      }
      return degreeA.compareTo(degreeB);
    });

    for (final candidate in candidates) {
      path.add(candidate);
      visited.add(candidate);

      if (_searchPath(size, total, path, visited, random)) {
        return true;
      }

      path.removeLast();
      visited.remove(candidate);
    }

    return false;
  }

  int _availableDegree(
    GridPosition position,
    int size,
    Set<GridPosition> visited,
  ) {
    return _neighbors(
      position,
      size,
    ).where((neighbor) => !visited.contains(neighbor)).length;
  }

  List<GridPosition> _neighbors(GridPosition position, int size) {
    final neighbors = <GridPosition>[];
    final deltas = [
      const GridPosition(-1, 0),
      const GridPosition(1, 0),
      const GridPosition(0, -1),
      const GridPosition(0, 1),
    ];

    for (final delta in deltas) {
      final row = position.row + delta.row;
      final col = position.col + delta.col;
      if (row >= 0 && row < size && col >= 0 && col < size) {
        neighbors.add(GridPosition(row, col));
      }
    }

    return neighbors;
  }

  List<List<CellData>> _assignCells({
    required List<GridPosition> path,
    required Difficulty difficulty,
    required Random random,
  }) {
    final size = difficulty.size;
    final grid = List.generate(
      size,
      (_) => List.generate(
        size,
        (_) => const CellData(color: CellColor.blue, value: 1),
      ),
    );

    final colors = CellColor.values;
    final switchDensity = switch (difficulty) {
      Difficulty.easy => 0.45,
      Difficulty.medium => 0.55,
      Difficulty.hard => 0.65,
    };

    var currentColor = colors[random.nextInt(colors.length)];
    var currentValue = random.nextInt(4) + 1;

    final first = path.first;
    grid[first.row][first.col] = CellData(
      color: currentColor,
      value: currentValue,
    );

    for (var i = 1; i < path.length; i++) {
      final mustSwitch = random.nextDouble() < switchDensity;
      CellColor nextColor = currentColor;
      int nextValue = currentValue;

      if (mustSwitch) {
        final options = colors.where((color) => color != currentColor).toList();
        nextColor = options[random.nextInt(options.length)];
        nextValue = currentValue;
      } else {
        final candidates = <int>[];
        if (currentValue > 1) {
          candidates.add(currentValue - 1);
        }
        if (currentValue < 4) {
          candidates.add(currentValue + 1);
        }

        if (candidates.isEmpty) {
          final options = colors
              .where((color) => color != currentColor)
              .toList();
          nextColor = options[random.nextInt(options.length)];
          nextValue = currentValue;
        } else {
          nextValue = candidates[random.nextInt(candidates.length)];
        }
      }

      currentColor = nextColor;
      currentValue = nextValue;

      final position = path[i];
      grid[position.row][position.col] = CellData(
        color: currentColor,
        value: currentValue,
      );

      final previous = path[i - 1];
      final isValid = _rules.isValidTransition(
        grid[previous.row][previous.col],
        grid[position.row][position.col],
      );
      if (!isValid) {
        throw StateError('Level invalido gerado para seed');
      }
    }

    return grid;
  }
}
