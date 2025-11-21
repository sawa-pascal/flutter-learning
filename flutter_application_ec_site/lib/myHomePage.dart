import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart.dart';
import 'myApiProvider.dart';
import 'models/userModel/userModel.dart';
import 'appBar.dart';
import 'userInfoSection.dart';
import 'item.dart';
import 'errorView.dart';

/// ホーム画面のウィジェット
class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  /// アプリバーに表示するタイトル
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 商品一覧データ（itemsProvider）を監視（非同期：ローディング・エラー・データ）
    final itemsAsync = ref.watch(itemsProvider);
    // ログイン済みユーザー情報（なければnull）
    final userModel = ref.watch(userModelProvider);

    return Scaffold(
      // アプリ共通のAppBar（appBar.dartのbuildAppBarを利用）
      appBar: buildAppBar(context, title, userModel),
      // メイン画面
      body: Column(
        children: [
          // ユーザー情報セクション（ログイン時は情報表示、未ログイン時は空白）
          UserInfoSection(userModel: userModel),
          // 商品リストやローディング・エラー表示部
          Expanded(child: _buildItemsSection(ref, itemsAsync)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const Cart()));
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.shopping_cart, color: Colors.white),
        tooltip: 'カートを見る',
      ),
    );
  }

  /// 商品リスト部分（ローディング・エラー・データを状態で切り替え）
  Widget _buildItemsSection(
    WidgetRef ref,
    AsyncValue<List<dynamic>> itemsAsync,
  ) {
    return itemsAsync.when(
      // ローディング中：インジケータ表示
      loading: () => const Center(child: CircularProgressIndicator()),
      // エラー時：エラー画面＋再試行ボタン
      error: (error, stack) => ErrorView(
        error: error,
        onRetry: () {
          // 再取得（ref.refreshはProvider自体を再構築する、future型で再fetch）
          ref.refresh(itemsProvider.future);
        },
      ),
      // 正常取得時：商品リストをリフレッシュ対応で表示
      data: (items) => RefreshIndicator(
        onRefresh: () async {
          // Providerを無効化して再フェッチ
          ref.invalidate(itemsProvider);
          // 完全リフレッシュが終わるまで待つ
          await ref.read(itemsProvider.future);
        },
        child: ItemList(items: items),
      ),
    );
  }
}
