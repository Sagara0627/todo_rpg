import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  final _textCtrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
    Future.delayed(
      const Duration(milliseconds: 120),
      () { if (mounted) _focus.requestFocus(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _textCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E24),
            border: Border.all(color: const Color(0xFFD4A017), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A017).withOpacity(0.28),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── title bar ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                color: const Color(0xFF1A1A3A),
                child: Text(
                  '⚔  しゅぎょうを　きろくする',
                  style: GoogleFonts.dotGothic16(
                    color: const Color(0xFFD4A017),
                    fontSize: 13,
                  ),
                ),
              ),
              // ── body ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'しゅぎょうの　ないよう：',
                      style: GoogleFonts.dotGothic16(
                        color: const Color(0xFF8AB4F8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textCtrl,
                      focusNode: _focus,
                      style: GoogleFonts.dotGothic16(
                        color: const Color(0xFFDDF0FF),
                        fontSize: 14,
                      ),
                      cursorColor: const Color(0xFFD4A017),
                      decoration: InputDecoration(
                        hintText: '例）　瞑想する・コードを書く',
                        hintStyle: GoogleFonts.dotGothic16(
                          color: Colors.white.withValues(alpha: 0.22),
                          fontSize: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                const Color(0xFF4A90D9).withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFD4A017),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF060618),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    _RpgButton(
                      label: 'けってい！',
                      color: const Color(0xFFD4A017),
                      onTap: _submit,
                    ),
                    const SizedBox(height: 8),
                    _RpgButton(
                      label: 'やめる',
                      color: const Color(0xFF4A90D9),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RpgButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RpgButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RpgButton> createState() => _RpgButtonState();
}

class _RpgButtonState extends State<_RpgButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: _pressed
                ? widget.color.withOpacity(0.18)
                : const Color(0xFF0E0E24),
            border: Border.all(color: widget.color, width: 2),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: widget.color.withOpacity(0.2),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.dotGothic16(
                color: widget.color,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
