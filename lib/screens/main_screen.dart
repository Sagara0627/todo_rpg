import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../services/sound_service.dart';
import '../widgets/pixel_character_widget.dart';
import '../widgets/status_bars_widget.dart';
import '../widgets/task_list_widget.dart';
import '../widgets/message_window_widget.dart';
import '../widgets/add_task_dialog.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  late final AnimationController _flashCtrl;
  late final Animation<double> _flashOpacity;

  bool _showLevelUpBanner = false;
  int _levelUpLevel = 1;
  int _sparkleKey = 0;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flashOpacity = CurvedAnimation(
      parent: _flashCtrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  // ── event handlers ──────────────────────────────────────────────────────────

  Future<void> _handleComplete(String id) async {
    final notifier = ref.read(gameProvider.notifier);
    final leveledUp = await notifier.completeTask(id);
    if (!mounted) return;

    setState(() => _sparkleKey++);

    if (leveledUp) {
      SoundService.playLevelUp();
      final lvl = ref.read(gameProvider).level;
      setState(() {
        _showLevelUpBanner = true;
        _levelUpLevel = lvl;
      });
      _flashCtrl.forward().then((_) => _flashCtrl.reverse());
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _showLevelUpBanner = false);
    } else {
      SoundService.playTaskComplete();
      _flashCtrl.forward(from: 0).then((_) => _flashCtrl.reverse());
    }

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) notifier.resetAnimation();
  }

  void _handleDelete(String id) {
    SoundService.playButton();
    ref.read(gameProvider.notifier).deleteTask(id);
  }

  Future<void> _handleAddTask() async {
    SoundService.playButton();
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => const AddTaskDialog(),
    );
    if (result != null && result.isNotEmpty && mounted) {
      SoundService.playAddTask();
      ref.read(gameProvider.notifier).addTask(result);
    }
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final w = MediaQuery.of(context).size.width;
    final maxW = w < 480.0 ? w : 480.0;

    return Scaffold(
      backgroundColor: const Color(0xFF080818),
      body: Stack(
        children: [
          // ① dungeon background (full screen)
          const _DungeonBg(),
          // ② CRT scanline overlay
          const _ScanlineOverlay(),
          // ③ sparkle burst
          SparkleOverlay(triggerKey: _sparkleKey),
          // ④ main scrollable content
          SafeArea(
            child: Center(
              child: SizedBox(
                width: maxW,
                child: Column(
                  children: [
                    _buildHeader(state),
                    _buildCharacterStage(state),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: StatusBarsWidget(state: state),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SingleChildScrollView(
                          child: TaskListWidget(
                            tasks: state.tasks,
                            onComplete: _handleComplete,
                            onDelete: _handleDelete,
                            onAddTask: _handleAddTask,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: MessageWindowWidget(message: state.message),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ⑤ screen flash
          AnimatedBuilder(
            animation: _flashOpacity,
            builder: (_, __) {
              if (_flashOpacity.value < 0.01) return const SizedBox.shrink();
              final col = _showLevelUpBanner
                  ? const Color(0xFFD4A017)
                  : const Color(0xFF44FF88);
              return IgnorePointer(
                child: Container(
                  color:
                      col.withOpacity((_flashOpacity.value * 0.35).clamp(0, 1)),
                ),
              );
            },
          ),
          // ⑥ level-up banner
          if (_showLevelUpBanner) _buildLevelUpBanner(_levelUpLevel),
        ],
      ),
    );
  }

  // ── sub-builders ─────────────────────────────────────────────────────────────

  Widget _buildHeader(GameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF080818).withOpacity(0.9),
      child: Row(
        children: [
          // glow title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFD4A017), Color(0xFFFFF3A0), Color(0xFFD4A017)],
            ).createShader(bounds),
            child: Text(
              '⚔  TODO RPG',
              style: GoogleFonts.dotGothic16(
                color: Colors.white,
                fontSize: 14,
                shadows: [
                  Shadow(
                    color: const Color(0xFFD4A017).withOpacity(0.6),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A38),
              border: Border.all(color: const Color(0xFFD4A017)),
            ),
            child: Text(
              'Lv. ${state.level}',
              style: GoogleFonts.dotGothic16(
                color: const Color(0xFFD4A017),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterStage(GameState state) {
    return Container(
      height: 178,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF090922), Color(0xFF111130)],
        ),
        border: Border.symmetric(
          vertical: BorderSide(
            color: const Color(0xFF4A90D9).withOpacity(0.4),
            width: 2,
          ),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // magic circle behind character
          Positioned.fill(
            child: _MagicCircle(active: state.isAnimating),
          ),
          // twinkling stars
          const Positioned.fill(child: _StarField()),
          // left torch
          const Positioned(left: 14, top: 18, child: _Torch()),
          // right torch
          const Positioned(right: 14, top: 18, child: _Torch()),
          // character + name
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                PixelCharacterWidget(
                  isAnimating: state.isAnimating,
                  isLevelUp: state.isLevelUp,
                ),
                const SizedBox(height: 2),
                Text(
                  '── HERO ──',
                  style: GoogleFonts.dotGothic16(
                    color: const Color(0xFF4A90D9).withOpacity(0.6),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          // floor gradient
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: 24,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF080818)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelUpBanner(int level) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 480),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D26),
            border: Border.all(color: const Color(0xFFD4A017), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A017).withOpacity(0.55),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('★  ★  ★',
                  style: GoogleFonts.dotGothic16(
                      color: const Color(0xFFD4A017), fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                'レベルアップ！',
                style: GoogleFonts.dotGothic16(
                  color: Colors.white,
                  fontSize: 22,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFD4A017).withOpacity(0.9),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lv. $level に　なった！',
                style: GoogleFonts.dotGothic16(
                  color: const Color(0xFFD4A017),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text('★  ★  ★',
                  style: GoogleFonts.dotGothic16(
                      color: const Color(0xFFD4A017), fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dungeon background
// ─────────────────────────────────────────────────────────────────────────────
class _DungeonBg extends StatelessWidget {
  const _DungeonBg();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DungeonPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DungeonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // base fill
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF080818),
    );

    // subtle grid
    final grid = Paint()
      ..color = const Color(0xFF4A90D9).withOpacity(0.035)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const cell = 32.0;
    for (var x = 0.0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // vignette
    final vig = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
        stops: const [0.45, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vig);
  }

  @override
  bool shouldRepaint(_DungeonPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CRT Scanline overlay
// ─────────────────────────────────────────────────────────────────────────────
class _ScanlineOverlay extends StatelessWidget {
  const _ScanlineOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ScanlinePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black.withOpacity(0.035)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated magic circle
// ─────────────────────────────────────────────────────────────────────────────
class _MagicCircle extends StatefulWidget {
  final bool active;
  const _MagicCircle({required this.active});

  @override
  State<_MagicCircle> createState() => _MagicCircleState();
}

class _MagicCircleState extends State<_MagicCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _MagicCirclePainter(
          angle: _ctrl.value * 2 * math.pi,
          active: widget.active,
        ),
      ),
    );
  }
}

class _MagicCirclePainter extends CustomPainter {
  final double angle;
  final bool active;

  const _MagicCirclePainter({required this.angle, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 22;
    const r = 52.0;
    final opacity = active ? 0.65 : 0.22;
    final col = active ? const Color(0xFFD4A017) : const Color(0xFF4A90D9);

    final stroke = Paint()
      ..color = col.withOpacity(opacity)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(cx, cy), r, stroke);
    canvas.drawCircle(Offset(cx, cy), r * 0.62,
        stroke..color = col.withOpacity(opacity * 0.7));
    canvas.drawCircle(Offset(cx, cy), r * 0.28,
        stroke..color = col.withOpacity(opacity * 0.5));

    // rotating rune dots (8 points)
    for (var i = 0; i < 8; i++) {
      final a = angle + i * math.pi / 4;
      final dot = Paint()..color = col.withOpacity(opacity * 0.9);
      canvas.drawCircle(
        Offset(cx + r * 0.82 * math.cos(a), cy + r * 0.82 * math.sin(a)),
        active ? 3.0 : 2.0,
        dot,
      );
    }

    // counter-rotating inner rune (6 points)
    for (var i = 0; i < 6; i++) {
      final a = -angle * 1.5 + i * math.pi / 3;
      final dot = Paint()
        ..color = col.withOpacity(opacity * 0.55);
      canvas.drawCircle(
        Offset(cx + r * 0.45 * math.cos(a), cy + r * 0.45 * math.sin(a)),
        1.5,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(_MagicCirclePainter old) =>
      old.angle != angle || old.active != active;
}

// ─────────────────────────────────────────────────────────────────────────────
// Twinkling star field
// ─────────────────────────────────────────────────────────────────────────────
class _StarField extends StatefulWidget {
  const _StarField();

  @override
  State<_StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<_StarField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = math.Random(42);
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(
      26,
      (i) => _Star(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        r: _rng.nextDouble() * 1.2 + 0.4,
        phase: _rng.nextDouble() * 2 * math.pi,
        speed: _rng.nextDouble() * 0.6 + 0.4,
      ),
    );
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _StarPainter(
          stars: _stars,
          t: _ctrl.value * 2 * math.pi,
        ),
      ),
    );
  }
}

class _Star {
  final double x, y, r, phase, speed;
  const _Star({
    required this.x,
    required this.y,
    required this.r,
    required this.phase,
    required this.speed,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  const _StarPainter({required this.stars, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity =
          ((math.sin(t * s.speed + s.phase) + 1) / 2 * 0.7 + 0.15)
              .clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated torch (pixel-art flame)
// ─────────────────────────────────────────────────────────────────────────────
class _Torch extends StatefulWidget {
  const _Torch();

  @override
  State<_Torch> createState() => _TorchState();
}

class _TorchState extends State<_Torch> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: const Size(12, 28),
        painter: _TorchPainter(t: _ctrl.value),
      ),
    );
  }
}

class _TorchPainter extends CustomPainter {
  final double t;
  const _TorchPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    // handle
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.55,
          size.width * 0.4, size.height * 0.45),
      Paint()..color = const Color(0xFF6B4423),
    );
    // flame core (orange)
    final flameH = size.height * 0.55 * (0.8 + t * 0.2);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.52 - flameH,
        size.width * 0.6,
        flameH,
      ),
      Paint()..color = const Color(0xFFFF8C00).withOpacity(0.9),
    );
    // flame tip (yellow)
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.52 - flameH * 0.75,
        size.width * 0.4,
        flameH * 0.55,
      ),
      Paint()..color = const Color(0xFFFFDD44).withOpacity(0.85),
    );
    // glow halo
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.35),
      size.width * (0.9 + t * 0.3),
      Paint()
        ..color = const Color(0xFFFF8C00).withOpacity(0.12 + t * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_TorchPainter old) => old.t != t;
}
