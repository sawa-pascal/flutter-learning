import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart.dart';
import 'myApiProvider.dart';
import 'models/userModel/userModel.dart';
import 'appBar.dart';
import 'item.dart';
import 'errorView.dart';

/// ホーム画面のウィジェット
class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  /// アプリバーに表示するタイトル
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  // 自動フォーカスしないためFocusNodeを削除
  String _searchKeyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ページが表示されるたびに商品一覧Providerをinvalidate
    // これにより常に最新の商品情報が取得される
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(itemsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 商品一覧データ（itemsProvider）を監視（非同期：ローディング・エラー・データ）
    final itemsAsync = ref.watch(itemsProvider);
    // ログイン済みユーザー情報（なければnull）
    final userModel = ref.watch(userModelProvider);

    return Scaffold(
      // アプリ共通のAppBar（appBar.dartのbuildAppBarを利用）
      appBar: buildAppBar(
        context,
        widget.title,
        userModel,
        onSearchPressed: () {}, // フォーカス処理を無効化
      ),
      // 検索フォーカス外し対応: GestureDetectorでラップ
      body: GestureDetector(
        // 画面のどこかをタップしたときに検索フィールドのフォーカスを外す
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            _buildSearchField(),
            // 商品リストやローディング・エラー表示部
            Expanded(child: _buildItemsSection(ref, itemsAsync)),
          ],
        ),
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

  // フォーカス処理を削除
  // void _focusSearchField() {
  //   FocusScope.of(context).requestFocus(_searchFocusNode);
  // }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        // focusNodeの指定を削除（自動フォーカスなし）
        onChanged: (value) {
          setState(() {
            _searchKeyword = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: '商品名で検索',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: _searchKeyword.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchKeyword = '';
                    });
                  },
                ),
        ),
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
          // Providerを無効化して再取得を促す
          ref.invalidate(itemsProvider);
        },
      ),
      // 正常取得時：商品リストをリフレッシュ対応で表示
      data: (items) {
        final filteredItems = _filterItems(items);
        final hasQuery = _searchKeyword.trim().isNotEmpty;
        final noItems = items.isEmpty;
        final noMatches = filteredItems.isEmpty;

        Widget listChild;
        if ((noItems && !hasQuery) || (noMatches && hasQuery)) {
          final message = noItems && !hasQuery
              ? '商品情報がありません'
              : '該当する商品が見つかりませんでした';
          listChild = _buildMessageList(message);
        } else {
          listChild = ItemList(items: filteredItems);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(itemsProvider);
            await ref.read(itemsProvider.future);
          },
          child: listChild,
        );
      },
    );
  }

  List<dynamic> _filterItems(List<dynamic> items) {
    final query = _searchKeyword.trim().toLowerCase();
    if (query.isEmpty) {
      return items;
    }

    return items.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }

  Widget _buildMessageList(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
