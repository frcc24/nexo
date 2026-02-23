import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/level_progress.dart';

class ProgressStorage {
  static const _progressKey = 'nexo_progress';
  static const _unlockedWorldKey = 'nexo_unlocked_world';
  static const _unlockedLevelKey = 'nexo_unlocked_level';
  static const _worldRuleSeenPrefix = 'nexo_world_rule_seen_';
  static const _debugUnlockAllKey = 'nexo_debug_unlock_all';

  Future<List<LevelProgress>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => LevelProgress.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProgress(List<LevelProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      progress.map((entry) => entry.toJson()).toList(),
    );
    await prefs.setString(_progressKey, payload);
  }

  Future<(int world, int level)> loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final world = prefs.getInt(_unlockedWorldKey) ?? 1;
    final level = prefs.getInt(_unlockedLevelKey) ?? 1;
    return (world, level);
  }

  Future<void> saveUnlocked({required int world, required int level}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unlockedWorldKey, world);
    await prefs.setInt(_unlockedLevelKey, level);
  }

  Future<bool> hasSeenWorldRule(int world) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_worldRuleSeenPrefix$world') ?? false;
  }

  Future<void> markWorldRuleSeen(int world) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_worldRuleSeenPrefix$world', true);
  }

  Future<bool> loadDebugUnlockAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_debugUnlockAllKey) ?? true;
  }

  Future<void> saveDebugUnlockAll(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_debugUnlockAllKey, enabled);
  }
}
