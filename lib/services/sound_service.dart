import 'dart:js_interop';

// Global JS function defined in web/index.html
@JS('playRPGSound')
external void _playRPGSound(JSString type);

class SoundService {
  static void playTaskComplete() => _call('complete');
  static void playLevelUp() => _call('levelup');
  static void playButton() => _call('button');
  static void playAddTask() => _call('add');

  static void _call(String type) {
    try {
      _playRPGSound(type.toJS);
    } catch (_) {}
  }
}
