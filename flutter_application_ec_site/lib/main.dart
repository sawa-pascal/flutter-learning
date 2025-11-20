import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'myHomePage.dart';

void main() => runApp(ProviderScope(child: const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //
    // ヘッダー(AppBar)がcyan色にならない理由:
    // ThemeData の primarySwatch: Colors.cyan は確かに
    // 昔のMaterial2のテーマではAppBarの色に反映されていました。
    // しかし最近のFlutter（Material 3）ではprimarySwatchやprimaryColorは
    // AppBarの背景色には自動で効きません。
    //
    // Material 3(Flutter 3.7以降あたりから)では
    // colorScheme や appBarTheme を調整しないと
    // ヘッダーの色が変わらないことがよくあります。
    //
    // 解決方法の例（appBarThemeで明示指定する）:
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true, // 必要に応じて
      ),
      home: const MyHomePage(title: 'S.A.アプリ'),
    );
  }
}
