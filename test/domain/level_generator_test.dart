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

  test('world 4 includes anchors and world 5 includes portals', () {
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
  });
}
