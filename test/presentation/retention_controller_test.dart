import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/level.dart';
import 'package:nexo/domain/services/level_generator.dart';
import 'package:nexo/presentation/controllers/retention_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('creates daily missions and records progress/achievements', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = RetentionController(
      now: () => DateTime(2026, 2, 23, 10),
    );

    await controller.init();

    expect(controller.dailyMissions.length, 3);
    expect(controller.achievements.where((a) => a.unlocked).length, 0);

    final level = LevelGenerator().generate(
      worldIndex: 1,
      levelIndex: 1,
      difficulty: Difficulty.easy,
    );

    final unlockedCount = await controller.recordLevelCompleted(
      level: level,
      stars: 3,
      score: 1200,
      hintsUsed: 0,
      isDailyChallenge: true,
    );

    expect(unlockedCount, greaterThanOrEqualTo(1));
    expect(controller.dailyCompleted, isTrue);
    expect(controller.dailyBestScore, 1200);
    expect(controller.dailyMissions.first.progress, greaterThanOrEqualTo(1));
    expect(
      controller.achievements.any((a) => a.id == 'first_win' && a.unlocked),
      isTrue,
    );

    final missionsAfterFirst = controller.dailyMissions
        .map((m) => (m.id, m.progress))
        .toList();
    final bestAfterFirst = controller.dailyBestScore;

    final secondUnlockedCount = await controller.recordLevelCompleted(
      level: level,
      stars: 3,
      score: 2000,
      hintsUsed: 0,
      isDailyChallenge: true,
    );

    expect(secondUnlockedCount, 0);
    expect(controller.dailyBestScore, bestAfterFirst);
    final missionsAfterSecond = controller.dailyMissions
        .map((m) => (m.id, m.progress))
        .toList();
    expect(missionsAfterSecond, missionsAfterFirst);
  });
}
