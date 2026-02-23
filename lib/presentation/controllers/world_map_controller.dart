import 'package:flutter/foundation.dart';

import '../../data/models/level_progress.dart';
import '../../data/storage/progress_storage.dart';
import '../../domain/entities/level.dart';
import '../../domain/services/level_generator.dart';

class WorldMapController extends ChangeNotifier {
  WorldMapController({ProgressStorage? storage, LevelGenerator? generator})
    : _storage = storage ?? ProgressStorage(),
      _generator = generator ?? LevelGenerator();

  static const int totalWorlds = 10;
  static const int levelsPerWorld = 20;

  final ProgressStorage _storage;
  final LevelGenerator _generator;

  final Map<String, LevelProgress> _progress = {};

  bool _initialized = false;
  int _unlockedWorld = 1;
  int _unlockedLevel = 1;
  bool _debugUnlockAllEnabled = true;

  bool get initialized => _initialized;
  bool get debugUnlockAllEnabled => _debugUnlockAllEnabled;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    final saved = await _storage.loadProgress();
    for (final entry in saved) {
      _progress[entry.key] = entry;
    }

    final unlocked = await _storage.loadUnlocked();
    _unlockedWorld = unlocked.$1;
    _unlockedLevel = unlocked.$2;
    if (kDebugMode) {
      _debugUnlockAllEnabled = await _storage.loadDebugUnlockAll();
    }

    _initialized = true;
    notifyListeners();
  }

  Difficulty difficultyForWorld(int world) {
    if (world <= 1) return Difficulty.easy;
    if (world == 2) return Difficulty.medium;
    return Difficulty.hard;
  }

  LevelData buildLevel({required int world, required int level}) {
    return _generator.generate(
      worldIndex: world,
      levelIndex: level,
      difficulty: difficultyForWorld(world),
    );
  }

  bool isUnlocked(int world, int level) {
    if (kDebugMode && _debugUnlockAllEnabled) {
      return true;
    }
    return _isUnlockedByProgress(world, level);
  }

  bool _isUnlockedByProgress(int world, int level) {
    if (world < _unlockedWorld) {
      return true;
    }
    if (world == _unlockedWorld) {
      return level <= _unlockedLevel;
    }
    return false;
  }

  bool canUnlockWithReward(int world, int level) {
    if (_isUnlockedByProgress(world, level)) {
      return false;
    }
    final nextLocked = _nextLevel(_unlockedWorld, _unlockedLevel);
    return world == nextLocked.$1 && level == nextLocked.$2;
  }

  Future<bool> unlockWithReward(int world, int level) async {
    if (!canUnlockWithReward(world, level)) {
      return false;
    }
    _unlockedWorld = world;
    _unlockedLevel = level;
    await _storage.saveUnlocked(world: _unlockedWorld, level: _unlockedLevel);
    notifyListeners();
    return true;
  }

  Future<void> setDebugUnlockAllEnabled(bool enabled) async {
    if (!kDebugMode) {
      return;
    }
    _debugUnlockAllEnabled = enabled;
    await _storage.saveDebugUnlockAll(enabled);
    notifyListeners();
  }

  int starsFor(int world, int level) {
    final key = '${world}_$level';
    return _progress[key]?.stars ?? 0;
  }

  bool isCompleted(int world, int level) {
    final key = '${world}_$level';
    return _progress[key]?.completed ?? false;
  }

  Future<void> completeLevel({
    required LevelData level,
    required int stars,
  }) async {
    final key = '${level.worldIndex}_${level.levelIndex}';
    final previous = _progress[key];
    final newStars = previous == null
        ? stars
        : (stars > previous.stars ? stars : previous.stars);
    _progress[key] = LevelProgress(
      world: level.worldIndex,
      level: level.levelIndex,
      seed: level.seed,
      completed: true,
      stars: newStars,
    );

    if (level.worldIndex == _unlockedWorld &&
        level.levelIndex == _unlockedLevel) {
      final next = _nextLevel(level.worldIndex, level.levelIndex);
      _unlockedWorld = next.$1;
      _unlockedLevel = next.$2;
      await _storage.saveUnlocked(world: _unlockedWorld, level: _unlockedLevel);
    }

    await _storage.saveProgress(_progress.values.toList());
    notifyListeners();
  }

  Future<bool> shouldShowWorldRuleIntro(int world) async {
    return !(await _storage.hasSeenWorldRule(world));
  }

  Future<void> markWorldRuleIntroSeen(int world) async {
    await _storage.markWorldRuleSeen(world);
  }

  (int, int) _nextLevel(int world, int level) {
    if (world == totalWorlds && level == levelsPerWorld) {
      return (world, level);
    }

    if (level < levelsPerWorld) {
      return (world, level + 1);
    }

    return (world + 1, 1);
  }
}
