import 'dart:async';

// ============================================================================
// 汎用ユーティリティ関数
// ============================================================================

/// 3桁ごとカンマ区切り金額String関数（package:intlなし独自実装）
/// 
/// [value]: フォーマットする数値
/// 
/// 戻り値: カンマ区切りの文字列
/// 
/// 例: formatYen(1234567) => "1,234,567"
String formatYen(int value) {
  final str = value.toString();
  final reg = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  return str.replaceAllMapped(reg, (m) => '${m[1]},');
}

// ============================================================================
// 長押しリピーター機能
// ============================================================================

/// 長押しリピーター用のタイマー（グローバル変数）
Timer? _longPressRepeaterTimer;

/// 長押しリピーターの実行間隔
const Duration _longPressRepeaterInterval = Duration(milliseconds: 100);

/// 長押しリピーターを開始
/// 
/// 長押し開始時、一定時間ごとにアクションを繰り返し実行します。
/// 
/// [action]: 繰り返し実行する関数
/// [onStart]: 開始時に実行する関数（省略可能）
/// 
/// 使用例:
/// ```dart
/// GestureDetector(
///   onLongPressStart: (details) {
///     startLongPressRepeater(() => doAction(), () => stopAction());
///   },
///   onLongPressEnd: (details) {
///     stopLongPressRepeater();
///   },
/// )
/// ```
void startLongPressRepeater(
  void Function() action, [
  void Function()? onStart,
]) {
  onStart?.call();
  action();
  _longPressRepeaterTimer = Timer.periodic(
    _longPressRepeaterInterval,
    (timer) {
      action();
    },
  );
}

/// 長押しリピーターを停止
/// 
/// [onEnd]: 停止時に実行する関数（省略可能）
void stopLongPressRepeater([void Function()? onEnd]) {
  _longPressRepeaterTimer?.cancel();
  _longPressRepeaterTimer = null;
  onEnd?.call();
}

// ============================================================================
// 文字列ユーティリティ
// ============================================================================

/// nullや空文字列の場合、デフォルト値で返す
/// 
/// [value]: チェックする文字列
/// [defaultValue]: デフォルト値（デフォルトは空文字列）
/// 
/// 戻り値: 値がnullまたは空の場合はdefaultValue、それ以外はvalue
String nullOrEmpty(String? value, {String defaultValue = ''}) {
  if (value == null || value.trim().isEmpty) return defaultValue;
  return value;
}

/// 0埋め（左側に0を追加）
/// 
/// [value]: 数値
/// [width]: 最終的な文字列の幅
/// 
/// 戻り値: 0埋めされた文字列
/// 
/// 例: leftPadZero(3, 5) => "00003"
String leftPadZero(int value, int width) {
  return value.toString().padLeft(width, '0');
}

