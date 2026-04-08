import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';

class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final Future<void> Function(String id) onComplete;
  final void Function(String id) onDelete;
  final VoidCallback onAddTask;

  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.onComplete,
    required this.onDelete,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    // incomplete first, then complete
    final sorted = [
      ...tasks.where((t) => !t.isCompleted),
      ...tasks.where((t) => t.isCompleted),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E24),
        border: Border.all(color: const Color(0xFF4A90D9), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── header ──
          _Header(onAddTask: onAddTask),
          // ── empty state ──
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(
                    '( 修行が　まだ　ない... )',
                    style: GoogleFonts.dotGothic16(
                      color: Colors.white24,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '「＋ 追加」で　きろくしよう',
                    style: GoogleFonts.dotGothic16(
                      color: Colors.white.withValues(alpha: 0.18),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          else
            ...sorted.map(
              (task) => TaskItemWidget(
                key: ValueKey(task.id),
                task: task,
                onComplete: onComplete,
                onDelete: onDelete,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatefulWidget {
  final VoidCallback onAddTask;
  const _Header({required this.onAddTask});

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      color: const Color(0xFF0A0A1E),
      child: Row(
        children: [
          Text(
            '⚔  今日の修行',
            style: GoogleFonts.dotGothic16(
              color: const Color(0xFFD4A017),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) {
              setState(() => _pressed = false);
              widget.onAddTask();
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _pressed
                    ? const Color(0xFFD4A017).withOpacity(0.2)
                    : Colors.transparent,
                border:
                    Border.all(color: const Color(0xFFD4A017), width: 1),
              ),
              child: Text(
                '＋ 追加',
                style: GoogleFonts.dotGothic16(
                  color: const Color(0xFFD4A017),
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task item ─────────────────────────────────────────────────────────────────
class TaskItemWidget extends StatefulWidget {
  final Task task;
  final Future<void> Function(String id) onComplete;
  final void Function(String id) onDelete;

  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  State<TaskItemWidget> createState() => _TaskItemWidgetState();
}

class _TaskItemWidgetState extends State<TaskItemWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashCtrl;
  late final Animation<Color?> _bgAnim;
  bool _tapping = false;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _bgAnim = ColorTween(
      begin: const Color(0xFF0E0E24),
      end: const Color(0xFF0B3020),
    ).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (widget.task.isCompleted) return;
    _flashCtrl.forward().then((_) {
      if (mounted) _flashCtrl.reverse();
    });
    await widget.onComplete(widget.task.id);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flashCtrl,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: _bgAnim.value,
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF4A90D9).withOpacity(0.18),
              ),
            ),
          ),
          child: Row(
            children: [
              // ── checkbox ──
              GestureDetector(
                onTap: _handleComplete,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: widget.task.isCompleted
                          ? const Color(0xFF44BB77)
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.task.isCompleted
                            ? const Color(0xFF44BB77)
                            : const Color(0xFF4A90D9),
                        width: 2,
                      ),
                    ),
                    child: widget.task.isCompleted
                        ? const Icon(Icons.check,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              // ── title ──
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 280),
                  style: GoogleFonts.dotGothic16(
                    color: widget.task.isCompleted
                        ? Colors.white.withValues(alpha: 0.28)
                        : const Color(0xFFE0F0FF),
                    fontSize: 13,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: Colors.white.withValues(alpha: 0.28),
                  ),
                  child: Text(widget.task.title),
                ),
              ),
              // ── xp badge ──
              if (widget.task.isCompleted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '+10XP',
                    style: GoogleFonts.dotGothic16(
                      color: const Color(0xFFD4A017),
                      fontSize: 9,
                    ),
                  ),
                ),
              // ── delete ──
              GestureDetector(
                onTapDown: (_) => setState(() => _tapping = true),
                onTapUp: (_) {
                  setState(() => _tapping = false);
                  widget.onDelete(widget.task.id);
                },
                onTapCancel: () => setState(() => _tapping = false),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _tapping ? 1.0 : 0.3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '×',
                      style: GoogleFonts.dotGothic16(
                        color: const Color(0xFFFF6B6B),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
