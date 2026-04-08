import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageWindowWidget extends StatefulWidget {
  final String message;
  const MessageWindowWidget({super.key, required this.message});

  @override
  State<MessageWindowWidget> createState() => _MessageWindowWidgetState();
}

class _MessageWindowWidgetState extends State<MessageWindowWidget>
    with SingleTickerProviderStateMixin {
  String _displayed = '';
  int _charIdx = 0;
  bool _typing = false;
  String _currentTarget = '';

  late final AnimationController _cursorCtrl;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..repeat(reverse: true);
    _startTyping(widget.message);
  }

  @override
  void didUpdateWidget(MessageWindowWidget old) {
    super.didUpdateWidget(old);
    if (widget.message != old.message) {
      _startTyping(widget.message);
    }
  }

  void _startTyping(String text) {
    _currentTarget = text;
    setState(() {
      _displayed = '';
      _charIdx = 0;
      _typing = true;
    });
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    if (_charIdx >= _currentTarget.length) {
      if (mounted) setState(() => _typing = false);
      return;
    }
    setState(() {
      _displayed = _currentTarget.substring(0, _charIdx + 1);
      _charIdx++;
    });
    Future.delayed(const Duration(milliseconds: 42), _tick);
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF08081C),
        border: Border.all(color: const Color(0xFF8AB4F8), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withOpacity(0.22),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── title bar ──
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: const Color(0xFF12123A),
            child: Row(
              children: [
                Text(
                  '▶ MESSAGE',
                  style: GoogleFonts.dotGothic16(
                    color: const Color(0xFF6A9FE8),
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _cursorCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _typing ? _cursorCtrl.value : 0,
                    child: Text(
                      '▼',
                      style: GoogleFonts.dotGothic16(
                        color: const Color(0xFFD4A017),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── message body ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '▶ ',
                  style: GoogleFonts.dotGothic16(
                    color: const Color(0xFFD4A017),
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: Text(
                    _displayed,
                    style: GoogleFonts.dotGothic16(
                      color: const Color(0xFFDDF0FF),
                      fontSize: 13,
                      height: 1.9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
