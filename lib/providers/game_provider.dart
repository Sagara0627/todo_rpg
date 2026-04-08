import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/game_state.dart';

class GameNotifier extends Notifier<GameState> {
  static const _tasksKey = 'rpg_tasks_v1';
  static const _levelKey = 'rpg_level_v1';
  static const _xpKey = 'rpg_xp_v1';

  @override
  GameState build() {
    _loadState();
    return const GameState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_tasksKey) ?? [];
    final tasks = raw.map((s) {
      try {
        return Task.fromJson(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<Task>().toList();

    state = state.copyWith(
      tasks: tasks,
      level: prefs.getInt(_levelKey) ?? 1,
      xp: prefs.getInt(_xpKey) ?? 0,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _tasksKey, state.tasks.map((t) => jsonEncode(t.toJson())).toList());
    await prefs.setInt(_levelKey, state.level);
    await prefs.setInt(_xpKey, state.xp);
  }

  Future<void> addTask(String title) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final task = Task(id: id, title: title, createdAt: DateTime.now());
    state = state.copyWith(
      tasks: [...state.tasks, task],
      message: '「$title」を\nしゅぎょうリストに　くわえた！',
      isAnimating: false,
      isLevelUp: false,
    );
    await _save();
  }

  /// Returns true if leveled up.
  Future<bool> completeTask(String id) async {
    final idx = state.tasks.indexWhere((t) => t.id == id);
    if (idx == -1 || state.tasks[idx].isCompleted) return false;

    final updated = List<Task>.from(state.tasks);
    updated[idx] = updated[idx].copyWith(isCompleted: true);

    int newXp = state.xp + 10;
    int newLevel = state.level;
    bool leveledUp = false;

    while (newXp >= newLevel * 50) {
      newXp -= newLevel * 50;
      newLevel++;
      leveledUp = true;
    }

    final title = state.tasks[idx].title;
    final allDone = updated.every((t) => t.isCompleted);

    String message;
    if (leveledUp) {
      message = '「$title」を　クリア！\n\n★ レベルが　${newLevel}に　あがった！ ★';
    } else if (allDone) {
      message = '★ 今日の　すべての\n　しゅぎょうを　おえた！\nおつかれさまでした！ ★';
    } else {
      message = '「$title」を　クリア！\nけいけんちを　10　もらった！';
    }

    state = state.copyWith(
      tasks: updated,
      xp: newXp,
      level: newLevel,
      message: message,
      isAnimating: true,
      isLevelUp: leveledUp,
    );
    await _save();
    return leveledUp;
  }

  void resetAnimation() {
    state = state.copyWith(isAnimating: false, isLevelUp: false);
  }

  Future<void> deleteTask(String id) async {
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != id).toList(),
      message: 'しゅぎょうを\nリストから　けした。',
      isAnimating: false,
    );
    await _save();
  }
}

final gameProvider =
    NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
