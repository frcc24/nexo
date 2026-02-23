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
    final size = _gridSizeForWorld(worldIndex, difficulty);

    final path = _buildHamiltonianPath(size: size, random: random);
    final grid = _assignCells(
      path: path,
      size: size,
      difficulty: difficulty,
      random: random,
    );
    final mechanics = _mechanicsForWorld(worldIndex);
    final anchors = mechanics.contains(LevelMechanic.anchors)
        ? _generateAnchors(path, levelIndex)
        : const <GridPosition>[];
    final portalPairs = mechanics.contains(LevelMechanic.portals)
        ? _generatePortalPairs(path: path, grid: grid, levelIndex: levelIndex)
        : const <PortalPair>[];
    final forcedDirections = mechanics.contains(LevelMechanic.arrows)
        ? _generateForcedDirections(path: path, levelIndex: levelIndex)
        : const <GridPosition, MoveDirection>{};

    return LevelData(
      worldIndex: worldIndex,
      levelIndex: levelIndex,
      seed: seed,
      difficulty: difficulty,
      grid: grid,
      solutionPath: path,
      mechanics: mechanics,
      anchors: anchors,
      portalPairs: portalPairs,
      forcedDirections: forcedDirections,
      gridSizeOverride: size == difficulty.size ? null : size,
    );
  }

  int _gridSizeForWorld(int worldIndex, Difficulty difficulty) {
    if (worldIndex == 9) {
      return 7;
    }
    if (worldIndex >= 10) {
      return 8;
    }
    return difficulty.size;
  }

  Set<LevelMechanic> _mechanicsForWorld(int worldIndex) {
    if (worldIndex == 4) {
      return {LevelMechanic.anchors};
    }
    if (worldIndex == 5) {
      return {LevelMechanic.portals};
    }
    if (worldIndex == 6) {
      return {LevelMechanic.anchors, LevelMechanic.portals};
    }
    if (worldIndex == 7) {
      return {LevelMechanic.arrows};
    }
    if (worldIndex >= 8) {
      return {
        LevelMechanic.anchors,
        LevelMechanic.portals,
        LevelMechanic.arrows,
      };
    }
    return const <LevelMechanic>{};
  }

  List<GridPosition> _buildHamiltonianPath({
    required int size,
    required Random random,
  }) {
    if (size >= 7) {
      final base = _buildSnakePath(size: size, random: random);
      return _shufflePathWithBackbite(path: base, random: random);
    }

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

  List<GridPosition> _buildSnakePath({
    required int size,
    required Random random,
  }) {
    final reverseRows = random.nextBool();
    final reverseCols = random.nextBool();
    final path = <GridPosition>[];

    for (var row = 0; row < size; row++) {
      final actualRow = reverseRows ? (size - 1 - row) : row;
      final leftToRight = row.isEven;
      for (var col = 0; col < size; col++) {
        final baseCol = leftToRight ? col : (size - 1 - col);
        final actualCol = reverseCols ? (size - 1 - baseCol) : baseCol;
        path.add(GridPosition(actualRow, actualCol));
      }
    }
    return path;
  }

  List<GridPosition> _shufflePathWithBackbite({
    required List<GridPosition> path,
    required Random random,
  }) {
    final working = List<GridPosition>.from(path);
    final total = working.length;
    final size = _inferSizeFromPath(working);
    final iterations = (total * 18) + random.nextInt(total * 6);

    for (var step = 0; step < iterations; step++) {
      final fromStart = random.nextBool();
      final endpoint = fromStart ? working.first : working.last;
      final blocked = fromStart ? working[1] : working[total - 2];

      final neighbors = _neighbors(
        endpoint,
        size,
      ).where((n) => n != blocked).toList();
      if (neighbors.isEmpty) {
        continue;
      }

      final target = neighbors[random.nextInt(neighbors.length)];
      final idx = working.indexOf(target);
      if (idx < 0) {
        continue;
      }
      if (fromStart) {
        if (idx <= 1) {
          continue;
        }
        final reversedPrefix = working.sublist(0, idx).reversed.toList();
        final suffix = working.sublist(idx);
        working
          ..clear()
          ..addAll(reversedPrefix)
          ..addAll(suffix);
      } else {
        if (idx >= total - 2) {
          continue;
        }
        final prefix = working.sublist(0, idx + 1);
        final reversedSuffix = working.sublist(idx + 1).reversed.toList();
        working
          ..clear()
          ..addAll(prefix)
          ..addAll(reversedSuffix);
      }
    }
    return working;
  }

  int _inferSizeFromPath(List<GridPosition> path) {
    var maxRow = 0;
    var maxCol = 0;
    for (final p in path) {
      if (p.row > maxRow) {
        maxRow = p.row;
      }
      if (p.col > maxCol) {
        maxCol = p.col;
      }
    }
    final size = max(maxRow, maxCol) + 1;
    return size <= 0 ? 1 : size;
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
    required int size,
    required Difficulty difficulty,
    required Random random,
  }) {
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

  List<GridPosition> _generateAnchors(List<GridPosition> path, int levelIndex) {
    final total = path.length;
    final maxAnchors = total >= 36 ? 4 : 3;
    final count = (2 + ((levelIndex - 1) ~/ 7)).clamp(2, maxAnchors);
    final result = <GridPosition>[];

    for (var i = 1; i <= count; i++) {
      final ratio = i / (count + 1);
      final idx = (ratio * (total - 1)).round().clamp(1, total - 2);
      result.add(path[idx]);
    }
    return result;
  }

  List<PortalPair> _generatePortalPairs({
    required List<GridPosition> path,
    required List<List<CellData>> grid,
    required int levelIndex,
  }) {
    final pairCount = levelIndex >= 12 ? 2 : 1;
    final pairs = <PortalPair>[];
    final used = <GridPosition>{};

    final candidates = <(GridPosition, GridPosition)>[];
    for (var i = 0; i < path.length; i++) {
      for (var j = i + 2; j < path.length; j++) {
        final a = path[i];
        final b = path[j];
        final valid = _rules.isValidTransition(
          grid[a.row][a.col],
          grid[b.row][b.col],
        );
        if (valid) {
          candidates.add((a, b));
        }
      }
    }

    for (final candidate in candidates) {
      if (pairs.length >= pairCount) {
        break;
      }
      final a = candidate.$1;
      final b = candidate.$2;
      if (used.contains(a) || used.contains(b)) {
        continue;
      }
      used.add(a);
      used.add(b);
      pairs.add(PortalPair(id: pairs.length + 1, a: a, b: b));
    }

    return pairs;
  }

  Map<GridPosition, MoveDirection> _generateForcedDirections({
    required List<GridPosition> path,
    required int levelIndex,
  }) {
    final total = path.length;
    final count = (2 + ((levelIndex - 1) ~/ 5)).clamp(2, 6);
    final result = <GridPosition, MoveDirection>{};
    final used = <GridPosition>{};

    for (var i = 1; i <= count; i++) {
      final ratio = i / (count + 1);
      final idx = (ratio * (total - 2)).round().clamp(0, total - 2);
      final current = path[idx];
      if (used.contains(current)) {
        continue;
      }
      final next = path[idx + 1];
      result[current] = MoveDirection.fromStep(from: current, to: next);
      used.add(current);
    }

    return result;
  }
}
