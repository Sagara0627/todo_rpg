import 'package:flutter/material.dart';
import 'dart:math' as math;

// ── Colour palette ──────────────────────────────────────────────────────────
const _palette = <int, Color>{
  1: Color(0xFFF5C5A3), // skin
  2: Color(0xFF3D2211), // hat / dark-brown
  3: Color(0xFF1B3FA0), // deep-blue robe
  4: Color(0xFF4B82F6), // robe highlight
  5: Color(0xFFF59E0B), // gold belt
  6: Color(0xFF0F1729), // very dark (eyes / boots)
  7: Color(0xFFF0F4FF), // white
  8: Color(0xFFC0392B), // mouth
  9: Color(0xFF132D7A), // robe shadow
};

// ── 16 × 20 pixel sprite ────────────────────────────────────────────────────
const _sprite = <List<int>>[
  [0,0,0,2,2,2,2,2,2,2,2,0,0,0,0,0], //  0  hat top
  [0,0,2,2,2,2,2,2,2,2,2,2,0,0,0,0], //  1  hat
  [0,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0], //  2  hat brim
  [0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0], //  3  forehead
  [0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0], //  4  face
  [0,0,0,1,6,6,1,1,1,6,6,1,0,0,0,0], //  5  eyes
  [0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0], //  6  cheeks
  [0,0,0,1,1,8,8,1,1,1,1,1,0,0,0,0], //  7  mouth
  [0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0], //  8  chin
  [0,0,0,0,3,3,1,1,3,3,0,0,0,0,0,0], //  9  collar
  [0,0,3,3,3,3,3,3,3,3,3,3,3,0,0,0], // 10  shoulders
  [0,3,3,4,3,3,3,3,3,3,4,3,3,3,0,0], // 11  sleeves
  [1,3,3,3,5,5,5,5,5,5,3,3,3,3,1,0], // 12  hands + belt
  [0,0,0,3,3,3,3,3,3,3,3,3,0,0,0,0], // 13  lower robe
  [0,0,0,3,4,3,3,3,3,3,4,3,0,0,0,0], // 14  robe detail
  [0,0,0,0,3,3,3,3,3,3,3,0,0,0,0,0], // 15  robe skirt
  [0,0,0,0,3,3,0,0,3,3,0,0,0,0,0,0], // 16  upper legs
  [0,0,0,0,6,3,0,0,6,3,0,0,0,0,0,0], // 17  legs
  [0,0,0,0,6,6,0,0,6,6,0,0,0,0,0,0], // 18  boots
  [0,0,0,0,6,0,0,0,0,6,0,0,0,0,0,0], // 19  boot tips
];

// ── Widget ───────────────────────────────────────────────────────────────────
class PixelCharacterWidget extends StatefulWidget {
  final bool isAnimating;
  final bool isLevelUp;

  const PixelCharacterWidget({
    super.key,
    this.isAnimating = false,
    this.isLevelUp = false,
  });

  @override
  State<PixelCharacterWidget> createState() => _PixelCharacterWidgetState();
}

class _PixelCharacterWidgetState extends State<PixelCharacterWidget>
    with TickerProviderStateMixin {
  late final AnimationController _idleCtrl;
  late final AnimationController _celebCtrl;
  late final AnimationController _levelUpCtrl;

  late final Animation<double> _floatY;
  late final Animation<double> _jumpY;
  late final Animation<double> _scale;
  late final Animation<double> _glowFade;

  @override
  void initState() {
    super.initState();

    // gentle idle float
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatY = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut),
    );

    // celebration jump
    _celebCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _jumpY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -36.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -36.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_celebCtrl);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.28)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.28, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_celebCtrl);

    // level-up golden glow
    _levelUpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _glowFade = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 60),
    ]).animate(_levelUpCtrl);
  }

  @override
  void didUpdateWidget(PixelCharacterWidget old) {
    super.didUpdateWidget(old);
    if (widget.isAnimating && !old.isAnimating) {
      _celebCtrl.forward(from: 0);
      if (widget.isLevelUp) {
        _levelUpCtrl.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _celebCtrl.dispose();
    _levelUpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleCtrl, _celebCtrl, _levelUpCtrl]),
      builder: (_, __) {
        final yOffset = _floatY.value +
            (_celebCtrl.isAnimating ? _jumpY.value : 0.0);
        final scale =
            _celebCtrl.isAnimating ? _scale.value : 1.0;
        final glow =
            _levelUpCtrl.isAnimating ? _glowFade.value : 0.0;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: const Size(96, 120),
              painter: _CharacterPainter(
                celebrating: _celebCtrl.isAnimating,
                glowIntensity: glow,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Painter ──────────────────────────────────────────────────────────────────
class _CharacterPainter extends CustomPainter {
  final bool celebrating;
  final double glowIntensity;

  const _CharacterPainter({
    this.celebrating = false,
    this.glowIntensity = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pW = size.width / 16;
    final pH = size.height / 20;

    for (var row = 0; row < _sprite.length; row++) {
      final rowData = _sprite[row];
      for (var col = 0; col < rowData.length; col++) {
        final idx = rowData[col];
        if (idx == 0) continue;

        var color = _palette[idx]!;

        // golden shimmer during celebration
        if (celebrating && (idx == 5 || idx == 4)) {
          color = Color.lerp(color, const Color(0xFFFFE566), 0.55)!;
        }
        // level-up full-body glow
        if (glowIntensity > 0 && idx != 6) {
          color =
              Color.lerp(color, const Color(0xFFFFF5AA), glowIntensity * 0.45)!;
        }

        canvas.drawRect(
          Rect.fromLTWH(col * pW, row * pH, pW, pH),
          Paint()..color = color,
        );
      }
    }

    // outer pixel-art shadow / drop
    if (glowIntensity > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..color = const Color(0xFFD4A017).withOpacity(glowIntensity * 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6),
      );
    }
  }

  @override
  bool shouldRepaint(_CharacterPainter old) =>
      old.celebrating != celebrating || old.glowIntensity != glowIntensity;
}

// ── Sparkle burst overlay ────────────────────────────────────────────────────
class SparkleOverlay extends StatefulWidget {
  final int triggerKey;

  const SparkleOverlay({super.key, required this.triggerKey});

  @override
  State<SparkleOverlay> createState() => _SparkleOverlayState();
}

class _SparkleOverlayState extends State<SparkleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.triggerKey > 0) _ctrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(SparkleOverlay old) {
    super.didUpdateWidget(old);
    if (widget.triggerKey != old.triggerKey && widget.triggerKey > 0) {
      _ctrl.forward(from: 0);
    }
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
      builder: (_, __) {
        if (_ctrl.value == 0) return const SizedBox.shrink();
        return IgnorePointer(
          child: CustomPaint(
            painter: _SparklePainter(t: _ctrl.value),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double t;
  const _SparklePainter({required this.t});

  // [angle_rad, speed, size]
  static const _pts = [
    [0.0, 100.0, 5.0],
    [0.785, 130.0, 4.0],
    [1.571, 110.0, 6.0],
    [2.356, 140.0, 4.0],
    [3.14159, 95.0, 5.0],
    [3.927, 125.0, 4.0],
    [4.712, 105.0, 6.0],
    [5.497, 135.0, 4.0],
    [0.4, 70.0, 3.0],
    [2.0, 80.0, 3.0],
    [3.6, 75.0, 3.0],
    [5.0, 85.0, 3.0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // burst from character centre (roughly top-third of screen)
    final cx = size.width / 2;
    final cy = size.height * 0.28;
    final opacity = t < 0.6 ? 1.0 : (1.0 - t) / 0.4;
    final eased = Curves.easeOut.transform(t);

    for (final p in _pts) {
      final dist = p[1] * eased;
      final x = cx + math.cos(p[0]) * dist;
      final y = cy + math.sin(p[0]) * dist;
      final r = p[2] * (1 - t * 0.6);

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = const Color(0xFFD4A017).withOpacity(opacity.clamp(0, 1)),
      );
      // small inner white highlight
      canvas.drawCircle(
        Offset(x, y),
        r * 0.4,
        Paint()..color = Colors.white.withOpacity((opacity * 0.8).clamp(0, 1)),
      );
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t;
}
