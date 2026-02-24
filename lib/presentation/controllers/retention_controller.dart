import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/storage/retention_storage.dart';
import '../../domain/entities/level.dart';
import '../../domain/services/level_generator.dart';
import 'world_map_controller.dart';

class DailyMission {
  const DailyMission({
    required this.id,
    required this.titleKey,
    required this.target,
    required this.progress,
  });

  final String id;
  final String titleKey;
  final int target;
  final int progress;

  bool get completed => progress >= target;

  DailyMission copyWith({int? progress}) {
    return DailyMission(
      id: id,
      titleKey: titleKey,
      target: target,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKey': titleKey,
      'target': target,
      'progress': progress,
    };
  }

  factory DailyMission.fromJson(Map<String, dynamic> json) {
    return DailyMission(
      id: json['id'] as String? ?? 'complete_levels',
      titleKey: json['titleKey'] as String? ?? 'mission_complete_levels',
      target: (json['target'] as num?)?.toInt() ?? 1,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
    );
  }
}

class AchievementProgress {
  const AchievementProgress({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.unlocked,
  });

  final String id;
  final String titleKey;
  final String descKey;
  final bool unlocked;
}

class _PlayerStats {
  const _PlayerStats({
    required this.totalWins,
    required this.totalStars,
    required this.noHintWins,
    required this.dailyChallengesCompleted,
  });

  final int totalWins;
  final int totalStars;
  final int noHintWins;
  final int dailyChallengesCompleted;

  _PlayerStats copyWith({
    int? totalWins,
    int? totalStars,
    int? noHintWins,
    int? dailyChallengesCompleted,
  }) {
    return _PlayerStats(
      totalWins: totalWins ?? this.totalWins,
      totalStars: totalStars ?? this.totalStars,
      noHintWins: noHintWins ?? this.noHintWins,
      dailyChallengesCompleted:
          dailyChallengesCompleted ?? this.dailyChallengesCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWins': totalWins,
      'totalStars': totalStars,
      'noHintWins': noHintWins,
      'dailyChallengesCompleted': dailyChallengesCompleted,
    };
  }

  factory _PlayerStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const _PlayerStats(
        totalWins: 0,
        totalStars: 0,
        noHintWins: 0,
        dailyChallengesCompleted: 0,
      );
    }
    return _PlayerStats(
      totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
      totalStars: (json['totalStars'] as num?)?.toInt() ?? 0,
      noHintWins: (json['noHintWins'] as num?)?.toInt() ?? 0,
      dailyChallengesCompleted:
          (json['dailyChallengesCompleted'] as num?)?.toInt() ?? 0,
    );
  }
}

class _AchievementDef {
  const _AchievementDef({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.check,
  });

  final String id;
  final String titleKey;
  final String descKey;
  final bool Function(_PlayerStats stats) check;
}

class RetentionController extends ChangeNotifier {
  RetentionController({
    RetentionStorage? storage,
    LevelGenerator? generator,
    DateTime Function()? now,
  }) : _storage = storage ?? RetentionStorage(),
       _generator = generator ?? LevelGenerator(),
       _now = now ?? DateTime.now;

  final RetentionStorage _storage;
  final LevelGenerator _generator;
  final DateTime Function() _now;

  bool _initialized = false;
  String _dailyDateKey = '';
  List<DailyMission> _dailyMissions = const [];
  int? _dailyBestScore;
  bool _dailyCompleted = false;
  _PlayerStats _stats = const _PlayerStats(
    totalWins: 0,
    totalStars: 0,
    noHintWins: 0,
    dailyChallengesCompleted: 0,
  );
  Set<String> _unlocked = <String>{};

  static final List<_AchievementDef> _achievementDefs = [
    _AchievementDef(
      id: 'first_win',
      titleKey: 'ach_first_win_title',
      descKey: 'ach_first_win_desc',
      check: (s) => s.totalWins >= 1,
    ),
    _AchievementDef(
      id: 'wins_20',
      titleKey: 'ach_wins_20_title',
      descKey: 'ach_wins_20_desc',
      check: (s) => s.totalWins >= 20,
    ),
    _AchievementDef(
      id: 'wins_100',
      titleKey: 'ach_wins_100_title',
      descKey: 'ach_wins_100_desc',
      check: (s) => s.totalWins >= 100,
    ),
    _AchievementDef(
      id: 'stars_200',
      titleKey: 'ach_stars_200_title',
      descKey: 'ach_stars_200_desc',
      check: (s) => s.totalStars >= 200,
    ),
    _AchievementDef(
      id: 'no_hint_25',
      titleKey: 'ach_no_hint_25_title',
      descKey: 'ach_no_hint_25_desc',
      check: (s) => s.noHintWins >= 25,
    ),
    _AchievementDef(
      id: 'daily_7',
      titleKey: 'ach_daily_7_title',
      descKey: 'ach_daily_7_desc',
      check: (s) => s.dailyChallengesCompleted >= 7,
    ),
  ];

  bool get initialized => _initialized;
  List<DailyMission> get dailyMissions => List.unmodifiable(_dailyMissions);
  int? get dailyBestScore => _dailyBestScore;
  bool get dailyCompleted => _dailyCompleted;
  int get unlockedAchievementsCount => _unlocked.length;
  int get totalAchievementsCount => _achievementDefs.length;

  List<AchievementProgress> get achievements {
    return _achievementDefs
        .map(
          (a) => AchievementProgress(
            id: a.id,
            titleKey: a.titleKey,
            descKey: a.descKey,
            unlocked: _unlocked.contains(a.id),
          ),
        )
        .toList();
  }

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    final today = _dateKey(_now());
    final raw = await _storage.loadState();
    _stats = _PlayerStats.fromJson(raw?['stats'] as Map<String, dynamic>?);
    _unlocked = ((raw?['unlocked'] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toSet();

    final savedDate = raw?['dailyDate'] as String?;
    if (savedDate == today) {
      _dailyDateKey = today;
      _dailyMissions = ((raw?['dailyMissions'] as List<dynamic>?) ?? const [])
          .map((e) => DailyMission.fromJson(e as Map<String, dynamic>))
          .toList();
      if (_dailyMissions.isEmpty) {
        _dailyMissions = _buildDailyMissions(today);
      }
      _dailyBestScore = (raw?['dailyBestScore'] as num?)?.toInt();
      _dailyCompleted = raw?['dailyCompleted'] == true;
    } else {
      _dailyDateKey = today;
      _dailyMissions = _buildDailyMissions(today);
      _dailyBestScore = null;
      _dailyCompleted = false;
      await _persist();
    }

    _initialized = true;
    notifyListeners();
  }

  LevelData buildDailyChallengeLevel() {
    final dayNumber = _dayNumber(_now());
    final world = (dayNumber % WorldMapController.totalWorlds) + 1;
    final level = ((dayNumber * 7) % WorldMapController.levelsPerWorld) + 1;
    final difficulty = _difficultyForWorld(world);
    return _generator.generate(
      worldIndex: world,
      levelIndex: level,
      difficulty: difficulty,
    );
  }

  Future<int> recordLevelCompleted({
    required LevelData level,
    required int stars,
    required int score,
    required int hintsUsed,
    required bool isDailyChallenge,
  }) async {
    if (!_initialized) {
      await init();
    }

    _stats = _stats.copyWith(
      totalWins: _stats.totalWins + 1,
      totalStars: _stats.totalStars + stars,
      noHintWins: _stats.noHintWins + (hintsUsed == 0 ? 1 : 0),
    );

    _incrementMission('complete_levels', 1);
    _incrementMission('collect_stars', stars);
    if (hintsUsed == 0) {
      _incrementMission('no_hint_wins', 1);
    }

    if (isDailyChallenge) {
      final wasCompleted = _dailyCompleted;
      _dailyCompleted = true;
      if (!wasCompleted) {
        _stats = _stats.copyWith(
          dailyChallengesCompleted: _stats.dailyChallengesCompleted + 1,
        );
      }
      if (_dailyBestScore == null || score > _dailyBestScore!) {
        _dailyBestScore = score;
      }
    }

    final newUnlocked = _unlockNewAchievements();
    await _persist();
    notifyListeners();
    return newUnlocked;
  }

  Difficulty _difficultyForWorld(int world) {
    if (world <= 1) return Difficulty.easy;
    if (world == 2) return Difficulty.medium;
    return Difficulty.hard;
  }

  List<DailyMission> _buildDailyMissions(String dateKey) {
    final random = Random(dateKey.hashCode);
    return [
      DailyMission(
        id: 'complete_levels',
        titleKey: 'mission_complete_levels',
        target: 3 + random.nextInt(3), // 3-5
        progress: 0,
      ),
      DailyMission(
        id: 'no_hint_wins',
        titleKey: 'mission_no_hint_wins',
        target: 1 + random.nextInt(2), // 1-2
        progress: 0,
      ),
      DailyMission(
        id: 'collect_stars',
        titleKey: 'mission_collect_stars',
        target: 6 + random.nextInt(5), // 6-10
        progress: 0,
      ),
    ];
  }

  void _incrementMission(String missionId, int amount) {
    _dailyMissions = _dailyMissions.map((mission) {
      if (mission.id != missionId || mission.completed) {
        return mission;
      }
      final next = mission.progress + amount;
      return mission.copyWith(
        progress: next > mission.target ? mission.target : next,
      );
    }).toList();
  }

  int _unlockNewAchievements() {
    var newUnlocked = 0;
    for (final def in _achievementDefs) {
      if (_unlocked.contains(def.id)) {
        continue;
      }
      if (def.check(_stats)) {
        _unlocked.add(def.id);
        newUnlocked++;
      }
    }
    return newUnlocked;
  }

  Future<void> _persist() async {
    await _storage.saveState({
      'dailyDate': _dailyDateKey,
      'dailyMissions': _dailyMissions.map((m) => m.toJson()).toList(),
      'dailyBestScore': _dailyBestScore,
      'dailyCompleted': _dailyCompleted,
      'stats': _stats.toJson(),
      'unlocked': _unlocked.toList(),
    });
  }

  String _dateKey(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  int _dayNumber(DateTime value) {
    final base = DateTime.utc(2024, 1, 1);
    final utc = DateTime.utc(value.year, value.month, value.day);
    return utc.difference(base).inDays.abs();
  }
}
