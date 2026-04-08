import 'task.dart';

class GameState {
  final List<Task> tasks;
  final int level;
  final int xp;
  final String message;
  final bool isAnimating;
  final bool isLevelUp;

  const GameState({
    this.tasks = const [],
    this.level = 1,
    this.xp = 0,
    this.message = 'ようこそ　勇者よ。\n今日の　修行を　はじめよう！',
    this.isAnimating = false,
    this.isLevelUp = false,
  });

  int get xpToNextLevel => level * 50;
  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.isCompleted).length;
  int get remainingTasks => totalTasks - completedTasks;
  bool get allDone => totalTasks > 0 && remainingTasks == 0;

  GameState copyWith({
    List<Task>? tasks,
    int? level,
    int? xp,
    String? message,
    bool? isAnimating,
    bool? isLevelUp,
  }) {
    return GameState(
      tasks: tasks ?? this.tasks,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      message: message ?? this.message,
      isAnimating: isAnimating ?? this.isAnimating,
      isLevelUp: isLevelUp ?? this.isLevelUp,
    );
  }
}
