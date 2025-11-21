import 'dart:async';

/// 汎用ユーティリティ関数置き場

/// 3桁ごとカンマ区切り金額String関数（package:intlなし独自実装）
/// 例: 1234567 -> "1,234,567"
String formatYen(int value) {
  final str = value.toString();
  final reg = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  return str.replaceAllMapped(reg, (m) => '${m[1]},');
}

/// 長押し（長押し開始時、一定時間ごと定期実行）
/// 引数: onLongPress (複数回呼びたい関数), onLongPressEnd (離した時の後処理)
/// 例: GestureDetectorで使う
///
/// return型は void
/// 例:
/// GestureDetector(
///   onLongPressStart: (details) {
///     startLongPressRepeater(() => doAction(), () => stopAction());
///   },
///   onLongPressEnd: (details) {
///     stopLongPressRepeater();
///   },
/// )
Timer? _longPressRepeaterTimer;

void startLongPressRepeater(void Function() action, [void Function()? onStart]) {
  onStart?.call();
  action();
  _longPressRepeaterTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
    action();
  });
}

void stopLongPressRepeater([void Function()? onEnd]) {
  _longPressRepeaterTimer?.cancel();
  _longPressRepeaterTimer = null;
  onEnd?.call();
}

/// nullや空文字列の場合、デフォルト値で返す
String nullOrEmpty(String? value, {String defaultValue = ''}) {
  if (value == null || value.trim().isEmpty) return defaultValue;
  return value;
}

/// 0埋め（例: leftPadZero(3, 5) => "00003"）
String leftPadZero(int value, int width) {
  return value.toString().padLeft(width, '0');
}

