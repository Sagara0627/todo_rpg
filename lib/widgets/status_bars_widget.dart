import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';

class StatusBarsWidget extends StatelessWidget {
  final GameState state;
  const StatusBarsWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final powerRatio = state.totalTasks == 0
        ? 0.0
        : (state.completedTasks / state.totalTasks).clamp(0.0, 1.0);
    final xpRatio =
        (state.xp / state.xpToNextLevel).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E24),
        border: Border.all(color: const Color(0xFF4A90D9), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withOpacity(0.18),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _Bar(
            label: '体力',
            ratio: powerRatio,
            barColor: state.allDone
                ? const Color(0xFFD4A017)
                : const Color(0xFF44CC88),
            dimColor: const Color(0xFF0D2B1A),
            leftText: state.allDone ? '全クリア！' : null,
            rightText:
                '${state.completedTasks}/${state.totalTasks == 0 ? "？" : state.totalTasks}',
          ),
          const SizedBox(height: 8),
          _Bar(
            label: 'EXP',
            ratio: xpRatio,
            barColor: const Color(0xFFD4A017),
            dimColor: const Color(0xFF2A1E00),
            rightText: '${state.xp}/${state.xpToNextLevel}',
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double ratio;
  final Color barColor;
  final Color dimColor;
  final String? leftText;
  final String rightText;

  const _Bar({
    required this.label,
    required this.ratio,
    required this.barColor,
    required this.dimColor,
    this.leftText,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            label,
            style: GoogleFonts.dotGothic16(
              color: const Color(0xFF8AB4F8),
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // track
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: dimColor,
                  border: Border.all(
                    color: barColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              // fill (animated)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    widthFactor: ratio,
                    heightFactor: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: barColor,
                        boxShadow: [
                          BoxShadow(
                            color: barColor.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // label text inside bar
              if (leftText != null)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    leftText!,
                    style: GoogleFonts.dotGothic16(
                      color: Colors.black87,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 50,
          child: Text(
            rightText,
            style: GoogleFonts.dotGothic16(
              color: const Color(0xFF8AB4F8),
              fontSize: 10,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
