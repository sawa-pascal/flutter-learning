import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart.dart';
import 'myApiProvider.dart';
import 'models/userModel/userModel.dart';
import 'appBar.dart';
import 'item.dart';
import 'errorView.dart';

// ============================================================================
// 定数定義
// ============================================================================

/// 検索フィールドのパディング
const EdgeInsets _searchFieldPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 8,
);

/// 検索フィールドのボーダー半径
const double _searchFieldBorderRadius = 12.0;

/// メッセージ表示のパディング
const EdgeInsets _messagePadding = EdgeInsets.all(24.0);

/// メッセージのフォントサイズ
const double _messageFontSize = 16.0;

// ============================================================================
// ホーム画面ウィジェット
// ============================================================================

/// ホーム画面のウィジェット
/// 
/// 商品一覧の表示、検索機能、カテゴリー選択によるスクロール機能を提供します。
class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  /// アプリバーに表示するタイトル
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  // ==========================================================================
  // 状態管理
  // ==========================================================================
  
  /// 検索フィールドのテキストコントローラー
  final TextEditingController _searchController = TextEditingController();
  
  /// 現在の検索キーワード
  String _searchKeyword = '';
  
  /// 商品リストのスクロールコントローラー
  final ScrollController _scrollController = ScrollController();
  
  /// 選択されたカテゴリーID（サイドメニューから選択された場合）
  int? _selectedCategoryId;

  // ==========================================================================
  // ライフサイクル
  // ==========================================================================

  @override
  void dispose() {
    // リソースのクリーンアップ
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ページが表示されるたびに商品一覧Providerを無効化
    // これにより常に最新の商品情報が取得される
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(itemsProvider);
    });
  }

  // ==========================================================================
  // ビルドメソッド
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // 商品一覧データを監視（非同期：ローディング・エラー・データ）
    final itemsAsync = ref.watch(itemsProvider);
    // ログイン済みユーザー情報（なければnull）
    final userModel = ref.watch(userModelProvider);

    return Scaffold(
      // サイドメニュー（カテゴリー選択機能付き）
      drawer: AppDrawer(
        onCategorySelected: _handleCategorySelected,
      ),
      // アプリ共通のAppBar
      appBar: buildAppBar(
        context,
        widget.title,
        userModel,
        onSearchPressed: () {}, // フォーカス処理は無効化
      ),
      // 検索フィールドと商品リスト
      body: GestureDetector(
        // 画面のどこかをタップしたときに検索フィールドのフォーカスを外す
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildSearchField(),
            Expanded(child: _buildItemsSection(ref, itemsAsync)),
          ],
        ),
      ),
      // カートへのショートカットボタン
      floatingActionButton: _buildCartFloatingActionButton(context),
    );
  }

  // ==========================================================================
  // イベントハンドラー
  // ==========================================================================

  /// カテゴリー選択時のハンドラー
  /// 
  /// サイドメニューからカテゴリーが選択されたときに呼ばれます。
  /// スクロール処理はItemList内で行われます。
  void _handleCategorySelected(int categoryId, String categoryName) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  /// カート画面への遷移
  void _navigateToCart(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Cart()),
    );
  }

  // ==========================================================================
  // UI構築メソッド
  // ==========================================================================

  /// 検索フィールドを構築
  /// 
  /// 商品名による検索機能を提供します。
  Widget _buildSearchField() {
    return Padding(
      padding: _searchFieldPadding,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchKeyword = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: '商品名で検索',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_searchFieldBorderRadius),
          ),
          suffixIcon: _searchKeyword.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                  tooltip: '検索をクリア',
                ),
        ),
      ),
    );
  }

  /// 検索フィールドをクリア
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchKeyword = '';
    });
  }

  /// カートへのフローティングアクションボタンを構築
  Widget _buildCartFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _navigateToCart(context),
      backgroundColor: Colors.orange,
      child: const Icon(Icons.shopping_cart, color: Colors.white),
      tooltip: 'カートを見る',
    );
  }

  /// 商品リストセクションを構築
  /// 
  /// ローディング、エラー、データの各状態に応じたUIを表示します。
  /// プルリフレッシュ機能も提供します。
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

        // 表示するウィジェットを決定
        Widget listChild;
        if ((noItems && !hasQuery) || (noMatches && hasQuery)) {
          final message = noItems && !hasQuery
              ? '商品情報がありません'
              : '該当する商品が見つかりませんでした';
          listChild = _buildMessageList(message);
        } else {
          listChild = ItemList(
            items: filteredItems,
            scrollController: _scrollController,
            selectedCategoryId: _selectedCategoryId,
            onCategoryScrolled: _handleCategoryScrolled,
          );
        }

        // プルリフレッシュ機能付きで返す
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

  /// カテゴリースクロール完了時のハンドラー
  /// 
  /// スクロール完了後に選択状態をリセットします。
  void _handleCategoryScrolled() {
    setState(() {
      _selectedCategoryId = null;
    });
  }

  /// 商品リストを検索キーワードでフィルタリング
  /// 
  /// [items]: フィルタリング対象の商品リスト
  /// 
  /// 戻り値: フィルタリングされた商品リスト
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

  /// メッセージ表示用のリストを構築
  /// 
  /// [message]: 表示するメッセージ
  Widget _buildMessageList(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: _messagePadding,
          child: Center(
            child: Text(
              message,
              style: const TextStyle(fontSize: _messageFontSize),
            ),
          ),
        ),
      ],
    );
  }
}
