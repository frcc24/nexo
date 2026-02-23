import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/level.dart';
import 'package:nexo/domain/services/game_rules.dart';
import 'package:nexo/domain/services/level_generator.dart';

void main() {
  test('generated level keeps valid transitions along guaranteed path', () {
    final generator = LevelGenerator();
    final rules = GameRules();

    final level = generator.generate(
      worldIndex: 2,
      levelIndex: 7,
      difficulty: Difficulty.medium,
    );

    expect(level.solutionPath.length, level.totalCells);

    for (var i = 0; i < level.solutionPath.length - 1; i++) {
      final current = level.solutionPath[i];
      final next = level.solutionPath[i + 1];

      expect(current.isOrthogonallyAdjacent(next), isTrue);
      expect(
        rules.isValidTransition(level.cellAt(current), level.cellAt(next)),
        isTrue,
      );
    }
  });

  test('worlds 4, 5, 6, 7, 8, 9 and 10 include expected mechanics', () {
    final generator = LevelGenerator();

    final world4 = generator.generate(
      worldIndex: 4,
      levelIndex: 3,
      difficulty: Difficulty.hard,
    );
    expect(world4.mechanics.contains(LevelMechanic.anchors), isTrue);
    expect(world4.anchors, isNotEmpty);

    final world5 = generator.generate(
      worldIndex: 5,
      levelIndex: 3,
      difficulty: Difficulty.hard,
    );
    expect(world5.mechanics.contains(LevelMechanic.portals), isTrue);
    expect(world5.portalPairs, isNotEmpty);

    final world6 = generator.generate(
      worldIndex: 6,
      levelIndex: 3,
      difficulty: Difficulty.hard,
    );
    expect(world6.mechanics.contains(LevelMechanic.anchors), isTrue);
    expect(world6.mechanics.contains(LevelMechanic.portals), isTrue);
    expect(world6.anchors, isNotEmpty);
    expect(world6.portalPairs, isNotEmpty);

    final world7 = generator.generate(
      worldIndex: 7,
      levelIndex: 3,
      difficulty: Difficulty.hard,
    );
    expect(world7.mechanics.contains(LevelMechanic.arrows), isTrue);
    expect(world7.forcedDirections, isNotEmpty);

    final world8 = generator.generate(
      worldIndex: 8,
      levelIndex: 3,
      difficulty: Difficulty.hard,
    );
    expect(world8.mechanics.contains(LevelMechanic.anchors), isTrue);
    expect(world8.mechanics.contains(LevelMechanic.portals), isTrue);
    expect(world8.mechanics.contains(LevelMechanic.arrows), isTrue);
    expect(world8.anchors, isNotEmpty);
    expect(world8.portalPairs, isNotEmpty);
    expect(world8.forcedDirections, isNotEmpty);

    final world9 = generator.generate(
      worldIndex: 9,
      levelIndex: 3,
      difficulty: Difficulty.hard,
    );
    expect(world9.gridSize, 7);
    expect(world9.totalCells, 49);
    expect(world9.solutionPath.length, 49);
    expect(world9.mechanics.contains(LevelMechanic.anchors), isTrue);
    expect(world9.mechanics.contains(LevelMechanic.portals), isTrue);
    expect(world9.mechanics.contains(LevelMechanic.arrows), isTrue);

    final world10 = generator.generate(
      worldIndex: 10,
      levelIndex: 3,
      difficulty: Difficulty.hard,
    );
    expect(world10.gridSize, 8);
    expect(world10.totalCells, 64);
    expect(world10.solutionPath.length, 64);
    expect(world10.mechanics.contains(LevelMechanic.anchors), isTrue);
    expect(world10.mechanics.contains(LevelMechanic.portals), isTrue);
    expect(world10.mechanics.contains(LevelMechanic.arrows), isTrue);
  });

  test('world 9 and 10 generate varied paths across levels', () {
    final generator = LevelGenerator();

    final world9Level1 = generator.generate(
      worldIndex: 9,
      levelIndex: 1,
      difficulty: Difficulty.hard,
    );
    final world9Level2 = generator.generate(
      worldIndex: 9,
      levelIndex: 2,
      difficulty: Difficulty.hard,
    );
    expect(world9Level1.solutionPath, isNot(equals(world9Level2.solutionPath)));

    final world10Level1 = generator.generate(
      worldIndex: 10,
      levelIndex: 1,
      difficulty: Difficulty.hard,
    );
    final world10Level2 = generator.generate(
      worldIndex: 10,
      levelIndex: 2,
      difficulty: Difficulty.hard,
    );
    expect(
      world10Level1.solutionPath,
      isNot(equals(world10Level2.solutionPath)),
    );
  });
}
