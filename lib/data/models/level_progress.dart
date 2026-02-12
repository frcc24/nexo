class LevelProgress {
  const LevelProgress({
    required this.world,
    required this.level,
    required this.seed,
    this.completed = false,
    this.stars = 0,
  });

  final int world;
  final int level;
  final int seed;
  final bool completed;
  final int stars;

  String get key => '${world}_$level';

  LevelProgress copyWith({bool? completed, int? stars}) {
    return LevelProgress(
      world: world,
      level: level,
      seed: seed,
      completed: completed ?? this.completed,
      stars: stars ?? this.stars,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'world': world,
      'level': level,
      'seed': seed,
      'completed': completed,
      'stars': stars,
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      world: (json['world'] as num?)?.toInt() ?? 1,
      level: (json['level'] as num?)?.toInt() ?? 1,
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      completed: json['completed'] == true,
      stars: (json['stars'] as num?)?.toInt() ?? 0,
    );
  }
}
