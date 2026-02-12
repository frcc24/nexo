import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/cell_data.dart';
import 'package:nexo/domain/entities/level.dart';
import 'package:nexo/domain/entities/position.dart';
import 'package:nexo/domain/services/game_rules.dart';

void main() {
  group('GameRules', () {
    final rules = GameRules();

    test('validates same color by difference of exactly one', () {
      const from = CellData(color: CellColor.blue, value: 2);
      const valid = CellData(color: CellColor.blue, value: 3);
      const invalid = CellData(color: CellColor.blue, value: 4);

      expect(rules.isValidTransition(from, valid), isTrue);
      expect(rules.isValidTransition(from, invalid), isFalse);
    });

    test('validates different color by same number', () {
      const from = CellData(color: CellColor.red, value: 3);
      const valid = CellData(color: CellColor.yellow, value: 3);
      const invalid = CellData(color: CellColor.blue, value: 4);

      expect(rules.isValidTransition(from, valid), isTrue);
      expect(rules.isValidTransition(from, invalid), isFalse);
    });

    test('valid move must be adjacent and non-repeated', () {
      final level = LevelData(
        worldIndex: 1,
        levelIndex: 1,
        seed: 1,
        difficulty: Difficulty.easy,
        grid: const [
          [
            CellData(color: CellColor.blue, value: 1),
            CellData(color: CellColor.red, value: 1),
            CellData(color: CellColor.yellow, value: 3),
            CellData(color: CellColor.yellow, value: 1),
          ],
          [
            CellData(color: CellColor.red, value: 2),
            CellData(color: CellColor.yellow, value: 2),
            CellData(color: CellColor.red, value: 2),
            CellData(color: CellColor.blue, value: 1),
          ],
          [
            CellData(color: CellColor.blue, value: 3),
            CellData(color: CellColor.red, value: 4),
            CellData(color: CellColor.yellow, value: 1),
            CellData(color: CellColor.blue, value: 2),
          ],
          [
            CellData(color: CellColor.red, value: 1),
            CellData(color: CellColor.yellow, value: 4),
            CellData(color: CellColor.blue, value: 4),
            CellData(color: CellColor.red, value: 3),
          ],
        ],
        solutionPath: const [],
      );

      const path = [GridPosition(0, 0)];
      expect(
        rules.isValidMove(
          level: level,
          path: path,
          next: const GridPosition(0, 1),
        ),
        isTrue,
      );
      expect(
        rules.isValidMove(
          level: level,
          path: path,
          next: const GridPosition(1, 1),
        ),
        isFalse,
      );
      expect(
        rules.isValidMove(
          level: level,
          path: path,
          next: const GridPosition(0, 0),
        ),
        isFalse,
      );
    });
  });
}
