import 'package:flutter/material.dart';

/// エラー時に表示するウィジェット
class ErrorView extends StatelessWidget {
  /// 発生したエラー情報
  final Object error;
  /// ユーザーによる「再試行」ボタン押下時に呼ばれるコールバック
  final VoidCallback onRetry;

  /// コンストラクタ
  const ErrorView({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  /// エラーメッセージを見やすく整形する
  String get _errorMessage {
    final msg = error.toString();
    // 空文字や内容がない場合は定型文に
    if (msg.trim().isEmpty || msg == 'Exception' || msg == 'Error') {
      return 'エラーが発生しました';
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // 表示幅を最大320pxに制限（スマホ・タブレット両対応）
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Card(
          // 外側の余白＋カードの影
          margin: const EdgeInsets.all(20),
          elevation: 2,
          child: Padding(
            // カード内部のパディング
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 赤いエラーアイコン
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                // エラーメッセージ表示
                Text(
                  _errorMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // 再試行ボタン
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('再試行'),
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
