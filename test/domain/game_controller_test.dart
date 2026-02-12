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
}
