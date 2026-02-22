import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/cell_data.dart';
import 'package:nexo/domain/entities/level.dart';
import 'package:nexo/domain/entities/position.dart';
import 'package:nexo/presentation/controllers/game_controller.dart';

void main() {
  test('tracks visited cells and progress correctly', () {
    final level = LevelData(
      worldIndex: 1,
      levelIndex: 1,
      seed: 1,
      difficulty: Difficulty.easy,
      grid: const [
        [
          CellData(color: CellColor.blue, value: 1),
          CellData(color: CellColor.red, value: 1),
          CellData(color: CellColor.yellow, value: 2),
          CellData(color: CellColor.blue, value: 2),
        ],
        [
          CellData(color: CellColor.red, value: 1),
          CellData(color: CellColor.yellow, value: 1),
          CellData(color: CellColor.blue, value: 1),
          CellData(color: CellColor.red, value: 2),
        ],
        [
          CellData(color: CellColor.yellow, value: 2),
          CellData(color: CellColor.blue, value: 2),
          CellData(color: CellColor.red, value: 2),
          CellData(color: CellColor.yellow, value: 3),
        ],
        [
          CellData(color: CellColor.blue, value: 3),
          CellData(color: CellColor.red, value: 3),
          CellData(color: CellColor.yellow, value: 4),
          CellData(color: CellColor.blue, value: 4),
        ],
      ],
      solutionPath: const [],
    );

    final controller = GameController(level: level);

    controller.trySelect(const GridPosition(0, 0));
    controller.trySelect(const GridPosition(0, 1));
    controller.trySelect(const GridPosition(1, 1));

    expect(controller.visitedCount, 3);
    expect(controller.progress, closeTo(3 / 16, 0.0001));

    controller.undo();
    expect(controller.visitedCount, 2);
    expect(controller.usedUndo, isTrue);

    controller.restart();
    expect(controller.visitedCount, 0);
    expect(controller.usedRestart, isTrue);
    expect(controller.stars, 1);
  });

  test('shows part of the correct path as hint and clears after move', () {
    final solution = List<GridPosition>.generate(
      16,
      (index) => GridPosition(index ~/ 4, index % 4),
    );
    final level = LevelData(
      worldIndex: 1,
      levelIndex: 1,
      seed: 1,
      difficulty: Difficulty.easy,
      grid: const [
        [
          CellData(color: CellColor.blue, value: 1),
          CellData(color: CellColor.red, value: 1),
          CellData(color: CellColor.yellow, value: 1),
          CellData(color: CellColor.blue, value: 1),
        ],
        [
          CellData(color: CellColor.red, value: 1),
          CellData(color: CellColor.yellow, value: 1),
          CellData(color: CellColor.blue, value: 1),
          CellData(color: CellColor.red, value: 1),
        ],
        [
          CellData(color: CellColor.yellow, value: 1),
          CellData(color: CellColor.blue, value: 1),
          CellData(color: CellColor.red, value: 1),
          CellData(color: CellColor.yellow, value: 1),
        ],
        [
          CellData(color: CellColor.blue, value: 1),
          CellData(color: CellColor.red, value: 1),
          CellData(color: CellColor.yellow, value: 1),
          CellData(color: CellColor.blue, value: 1),
        ],
      ],
      solutionPath: solution,
    );

    final controller = GameController(level: level);

    controller.showHint(segmentLength: 3);
    expect(controller.activeHint.length, 3);
    expect(controller.activeHint.first, solution.first);

    controller.trySelect(const GridPosition(0, 0));
    expect(controller.activeHint, isEmpty);
  });

  test('detects route deviation and suggests expected next cell', () {
    const grid = [
      [
        CellData(color: CellColor.blue, value: 1),
        CellData(color: CellColor.red, value: 1),
        CellData(color: CellColor.blue, value: 1),
        CellData(color: CellColor.red, value: 1),
      ],
      [
        CellData(color: CellColor.red, value: 1),
        CellData(color: CellColor.blue, value: 1),
        CellData(color: CellColor.red, value: 1),
        CellData(color: CellColor.blue, value: 1),
      ],
      [
        CellData(color: CellColor.blue, value: 1),
        CellData(color: CellColor.red, value: 1),
        CellData(color: CellColor.blue, value: 1),
        CellData(color: CellColor.red, value: 1),
      ],
      [
        CellData(color: CellColor.red, value: 1),
        CellData(color: CellColor.blue, value: 1),
        CellData(color: CellColor.red, value: 1),
        CellData(color: CellColor.blue, value: 1),
      ],
    ];
    final solution = <GridPosition>[
      const GridPosition(0, 0),
      const GridPosition(0, 1),
      const GridPosition(0, 2),
      const GridPosition(0, 3),
      const GridPosition(1, 3),
      const GridPosition(1, 2),
      const GridPosition(1, 1),
      const GridPosition(1, 0),
      const GridPosition(2, 0),
      const GridPosition(2, 1),
      const GridPosition(2, 2),
      const GridPosition(2, 3),
      const GridPosition(3, 3),
      const GridPosition(3, 2),
      const GridPosition(3, 1),
      const GridPosition(3, 0),
    ];
    final level = LevelData(
      worldIndex: 1,
      levelIndex: 1,
      seed: 1,
      difficulty: Difficulty.easy,
      grid: grid,
      solutionPath: solution,
    );

    final controller = GameController(level: level);
    controller.trySelect(const GridPosition(0, 0));
    controller.trySelect(const GridPosition(1, 0)); // valido, mas fora da rota

    expect(controller.hasRouteError, isTrue);
    expect(controller.firstWrongCell, const GridPosition(1, 0));
    expect(controller.expectedNextCorrectCell, const GridPosition(0, 1));
    expect(controller.hintFeedbackVisible, isFalse);

    controller.showHint(segmentLength: 3);
    expect(controller.hintFeedbackVisible, isTrue);
    expect(controller.hintWrongCell, const GridPosition(1, 0));
    expect(controller.hintExpectedCell, const GridPosition(0, 1));
    expect(controller.activeHint, [
      const GridPosition(0, 0),
      const GridPosition(0, 1),
      const GridPosition(0, 2),
    ]);

    controller.trySelect(const GridPosition(1, 1));
    expect(controller.hintFeedbackVisible, isFalse);
    expect(controller.hintWrongCell, isNull);
    expect(controller.hintExpectedCell, isNull);
    expect(controller.activeHint, isEmpty);
  });
}
