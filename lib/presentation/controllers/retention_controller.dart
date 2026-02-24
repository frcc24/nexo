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
    required this.rewardCoins,
    required this.rewardClaimed,
  });

  final String id;
  final String titleKey;
  final int target;
  final int progress;
  final int rewardCoins;
  final bool rewardClaimed;

  bool get completed => progress >= target;

  DailyMission copyWith({int? progress, bool? rewardClaimed}) {
    return DailyMission(
      id: id,
      titleKey: titleKey,
      target: target,
      progress: progress ?? this.progress,
      rewardCoins: rewardCoins,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKey': titleKey,
      'target': target,
      'progress': progress,
      'rewardCoins': rewardCoins,
      'rewardClaimed': rewardClaimed,
    };
  }

  factory DailyMission.fromJson(Map<String, dynamic> json) {
    return DailyMission(
      id: json['id'] as String? ?? 'complete_levels',
      titleKey: json['titleKey'] as String? ?? 'mission_complete_levels',
      target: (json['target'] as num?)?.toInt() ?? 1,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      rewardCoins: (json['rewardCoins'] as num?)?.toInt() ?? 40,
      rewardClaimed: json['rewardClaimed'] == true,
    );
  }
}

class AchievementProgress {
  const AchievementProgress({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.category,
    required this.iconKey,
    required this.unlocked,
  });

  final String id;
  final String titleKey;
  final String descKey;
  final AchievementCategory category;
  final String iconKey;
  final bool unlocked;
}

enum AchievementCategory { progress, mastery, daily }

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
    required this.category,
    required this.iconKey,
    required this.check,
  });

  final String id;
  final String titleKey;
  final String descKey;
  final AchievementCategory category;
  final String iconKey;
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
  int _coins = 0;
  int _lastCoinsEarned = 0;
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
      category: AchievementCategory.progress,
      iconKey: 'rocket',
      check: (s) => s.totalWins >= 1,
    ),
    _AchievementDef(
      id: 'wins_5',
      titleKey: 'ach_wins_5_title',
      descKey: 'ach_wins_5_desc',
      category: AchievementCategory.progress,
      iconKey: 'medal',
      check: (s) => s.totalWins >= 5,
    ),
    _AchievementDef(
      id: 'wins_20',
      titleKey: 'ach_wins_20_title',
      descKey: 'ach_wins_20_desc',
      category: AchievementCategory.progress,
      iconKey: 'target',
      check: (s) => s.totalWins >= 20,
    ),
    _AchievementDef(
      id: 'wins_50',
      titleKey: 'ach_wins_50_title',
      descKey: 'ach_wins_50_desc',
      category: AchievementCategory.progress,
      iconKey: 'trophy',
      check: (s) => s.totalWins >= 50,
    ),
    _AchievementDef(
      id: 'wins_100',
      titleKey: 'ach_wins_100_title',
      descKey: 'ach_wins_100_desc',
      category: AchievementCategory.progress,
      iconKey: 'crown',
      check: (s) => s.totalWins >= 100,
    ),
    _AchievementDef(
      id: 'wins_150',
      titleKey: 'ach_wins_150_title',
      descKey: 'ach_wins_150_desc',
      category: AchievementCategory.progress,
      iconKey: 'diamond',
      check: (s) => s.totalWins >= 150,
    ),
    _AchievementDef(
      id: 'stars_50',
      titleKey: 'ach_stars_50_title',
      descKey: 'ach_stars_50_desc',
      category: AchievementCategory.progress,
      iconKey: 'spark',
      check: (s) => s.totalStars >= 50,
    ),
    _AchievementDef(
      id: 'stars_200',
      titleKey: 'ach_stars_200_title',
      descKey: 'ach_stars_200_desc',
      category: AchievementCategory.progress,
      iconKey: 'stars',
      check: (s) => s.totalStars >= 200,
    ),
    _AchievementDef(
      id: 'stars_500',
      titleKey: 'ach_stars_500_title',
      descKey: 'ach_stars_500_desc',
      category: AchievementCategory.progress,
      iconKey: 'gem',
      check: (s) => s.totalStars >= 500,
    ),
    _AchievementDef(
      id: 'stars_1000',
      titleKey: 'ach_stars_1000_title',
      descKey: 'ach_stars_1000_desc',
      category: AchievementCategory.progress,
      iconKey: 'galaxy',
      check: (s) => s.totalStars >= 1000,
    ),
    _AchievementDef(
      id: 'no_hint_5',
      titleKey: 'ach_no_hint_5_title',
      descKey: 'ach_no_hint_5_desc',
      category: AchievementCategory.mastery,
      iconKey: 'shield',
      check: (s) => s.noHintWins >= 5,
    ),
    _AchievementDef(
      id: 'no_hint_25',
      titleKey: 'ach_no_hint_25_title',
      descKey: 'ach_no_hint_25_desc',
      category: AchievementCategory.mastery,
      iconKey: 'brain',
      check: (s) => s.noHintWins >= 25,
    ),
    _AchievementDef(
      id: 'no_hint_50',
      titleKey: 'ach_no_hint_50_title',
      descKey: 'ach_no_hint_50_desc',
      category: AchievementCategory.mastery,
      iconKey: 'focus',
      check: (s) => s.noHintWins >= 50,
    ),
    _AchievementDef(
      id: 'no_hint_100',
      titleKey: 'ach_no_hint_100_title',
      descKey: 'ach_no_hint_100_desc',
      category: AchievementCategory.mastery,
      iconKey: 'mastermind',
      check: (s) => s.noHintWins >= 100,
    ),
    _AchievementDef(
      id: 'daily_3',
      titleKey: 'ach_daily_3_title',
      descKey: 'ach_daily_3_desc',
      category: AchievementCategory.daily,
      iconKey: 'calendar',
      check: (s) => s.dailyChallengesCompleted >= 3,
    ),
    _AchievementDef(
      id: 'daily_7',
      titleKey: 'ach_daily_7_title',
      descKey: 'ach_daily_7_desc',
      category: AchievementCategory.daily,
      iconKey: 'calendar',
      check: (s) => s.dailyChallengesCompleted >= 7,
    ),
    _AchievementDef(
      id: 'daily_14',
      titleKey: 'ach_daily_14_title',
      descKey: 'ach_daily_14_desc',
      category: AchievementCategory.daily,
      iconKey: 'calendar_fire',
      check: (s) => s.dailyChallengesCompleted >= 14,
    ),
    _AchievementDef(
      id: 'daily_30',
      titleKey: 'ach_daily_30_title',
      descKey: 'ach_daily_30_desc',
      category: AchievementCategory.daily,
      iconKey: 'calendar_star',
      check: (s) => s.dailyChallengesCompleted >= 30,
    ),
    _AchievementDef(
      id: 'daily_60',
      titleKey: 'ach_daily_60_title',
      descKey: 'ach_daily_60_desc',
      category: AchievementCategory.daily,
      iconKey: 'calendar_bolt',
      check: (s) => s.dailyChallengesCompleted >= 60,
    ),
    _AchievementDef(
      id: 'daily_100',
      titleKey: 'ach_daily_100_title',
      descKey: 'ach_daily_100_desc',
      category: AchievementCategory.daily,
      iconKey: 'calendar_crown',
      check: (s) => s.dailyChallengesCompleted >= 100,
    ),
  ];

  bool get initialized => _initialized;
  List<DailyMission> get dailyMissions => List.unmodifiable(_dailyMissions);
  int? get dailyBestScore => _dailyBestScore;
  bool get dailyCompleted => _dailyCompleted;
  bool get canPlayDailyChallenge => !_dailyCompleted;
  int get coins => _coins;
  int get lastCoinsEarned => _lastCoinsEarned;
  int get unlockedAchievementsCount => _unlocked.length;
  int get totalAchievementsCount => _achievementDefs.length;

  List<AchievementProgress> get achievements {
    return _achievementDefs
        .map(
          (a) => AchievementProgress(
            id: a.id,
            titleKey: a.titleKey,
            descKey: a.descKey,
            category: a.category,
            iconKey: a.iconKey,
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
    _coins = (raw?['coins'] as num?)?.toInt() ?? 0;
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

    if (isDailyChallenge && _dailyCompleted) {
      _lastCoinsEarned = 0;
      return 0;
    }

    _stats = _stats.copyWith(
      totalWins: _stats.totalWins + 1,
      totalStars: _stats.totalStars + stars,
      noHintWins: _stats.noHintWins + (hintsUsed == 0 ? 1 : 0),
    );

    var coinsEarned = 0;
    coinsEarned += _incrementMission('complete_levels', 1);
    coinsEarned += _incrementMission('collect_stars', stars);
    if (hintsUsed == 0) {
      coinsEarned += _incrementMission('no_hint_wins', 1);
    }
    _coins += coinsEarned;
    _lastCoinsEarned = coinsEarned;

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

  int coinCostForLevel({required int world, required int level}) {
    return 60 + (world * 12) + (level * 2);
  }

  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) {
      return true;
    }
    if (_coins < amount) {
      return false;
    }
    _coins -= amount;
    await _persist();
    notifyListeners();
    return true;
  }

  List<DailyMission> _buildDailyMissions(String dateKey) {
    final random = Random(dateKey.hashCode);
    return [
      DailyMission(
        id: 'complete_levels',
        titleKey: 'mission_complete_levels',
        target: 3 + random.nextInt(3), // 3-5
        progress: 0,
        rewardCoins: 40 + random.nextInt(16),
        rewardClaimed: false,
      ),
      DailyMission(
        id: 'no_hint_wins',
        titleKey: 'mission_no_hint_wins',
        target: 1 + random.nextInt(2), // 1-2
        progress: 0,
        rewardCoins: 50 + random.nextInt(16),
        rewardClaimed: false,
      ),
      DailyMission(
        id: 'collect_stars',
        titleKey: 'mission_collect_stars',
        target: 6 + random.nextInt(5), // 6-10
        progress: 0,
        rewardCoins: 45 + random.nextInt(16),
        rewardClaimed: false,
      ),
    ];
  }

  int _incrementMission(String missionId, int amount) {
    var earned = 0;
    _dailyMissions = _dailyMissions.map((mission) {
      if (mission.id != missionId || mission.completed) {
        return mission;
      }
      final next = mission.progress + amount;
      final updated = mission.copyWith(
        progress: next > mission.target ? mission.target : next,
      );
      if (!mission.rewardClaimed && updated.completed) {
        earned += mission.rewardCoins;
        return updated.copyWith(rewardClaimed: true);
      }
      return updated;
    }).toList();
    return earned;
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
      'coins': _coins,
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
