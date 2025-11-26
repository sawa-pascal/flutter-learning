import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'myHomePage.dart';

/// アプリケーションのエントリーポイント
/// 
/// RiverpodのProviderScopeでアプリ全体をラップし、
/// 状態管理の基盤を提供します。
void main() => runApp(const ProviderScope(child: MyApp()));

/// アプリケーションのルートウィジェット
/// 
/// MaterialAppを設定し、アプリ全体のテーマとルーティングを管理します。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S.A.アプリ',
      theme: _buildTheme(),
      home: const MyHomePage(title: 'S.A.アプリ'),
      debugShowCheckedModeBanner: false,
    );
  }

  /// アプリケーションのテーマを構築
  /// 
  /// Material 3を使用し、カラースキームとAppBarのテーマを設定します。
  /// Material 3では、primarySwatchやprimaryColorはAppBarの背景色に
  /// 自動的に反映されないため、appBarThemeで明示的に指定する必要があります。
  ThemeData _buildTheme() {
    return ThemeData(
      // Material 3のカラースキームを設定
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan,
        brightness: Brightness.light,
      ),
      // AppBarのテーマを明示的に設定
      // Material 3では、colorSchemeだけではAppBarの色が変わらないため
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      // Material 3を有効化
      useMaterial3: true,
    );
  }
}
