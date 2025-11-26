import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_ec_site/passwordChange.dart';
import 'package:flutter_application_ec_site/userSetting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'cart.dart';
import 'managementSystemWidget/managementSystemWidget.dart';
import 'models/userModel/userModel.dart';
import 'purchaseHistory.dart';
import 'myApiProvider.dart';

// ============================================================================
// 型定義
// ============================================================================

/// カテゴリー選択時のコールバック関数の型定義
///
/// [categoryId]: 選択されたカテゴリーのID
/// [categoryName]: 選択されたカテゴリーの名前
typedef OnCategorySelected = void Function(int categoryId, String categoryName);

// ============================================================================
// 定数定義
// ============================================================================

/// ドロワーヘッダーの高さ
const double _drawerHeaderHeight = 100.0;

/// ドロワーヘッダーの画像URL
const String _drawerHeaderImageUrl =
    'http://3.107.37.75/images/stationery.jpeg';

/// カテゴリーセクションのパディング
const EdgeInsets _categorySectionPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 8,
);

/// AppBarのタイトルフォントサイズ
const double _appBarTitleFontSize = 30.0;

/// AppBarのタイトル色
const Color _appBarTitleColor = Colors.green;

/// AppBarの背景色
const Color _appBarBackgroundColor = Colors.red;

/// AppBarのelevation
const double _appBarElevation = 10.0;

// ============================================================================
// サイドメニュー（Drawer）ウィジェット
// ============================================================================

/// サイドメニュー（Drawer）ウィジェット
///
/// カテゴリー一覧を表示し、カテゴリー選択時にコールバックを実行します。
class AppDrawer extends ConsumerWidget {
  /// カテゴリー選択時のコールバック
  final OnCategorySelected? onCategorySelected;

  const AppDrawer({Key? key, this.onCategorySelected}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SafeArea(
      child: Drawer(
        child: ListView(
          children: [
            _buildDrawerHeader(),
            _buildCategorySection(context),
            _buildCategoryList(context, ref, categoriesAsync),

            const Divider(),

            ListTile(
              title: Text('管理画面を開く'),
              leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
              onTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).push(MaterialPageRoute(builder: (context) => const ManagementSystemWidget())),
            ),
          ],
        ),
      ),
    );
  }

  /// ドロワーヘッダーを構築
  Widget _buildDrawerHeader() {
    return SizedBox(
      height: _drawerHeaderHeight,
      child: DrawerHeader(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(_drawerHeaderImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }

  /// カテゴリーセクションのタイトルを構築
  Widget _buildCategorySection(BuildContext context) {
    return Padding(
      padding: _categorySectionPadding,
      child: Text('カテゴリー', style: Theme.of(context).textTheme.titleMedium),
    );
  }

  /// カテゴリーリストを構築
  Widget _buildCategoryList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<dynamic>> categoriesAsync,
  ) {
    return categoriesAsync.when(
      data: (categories) => _buildCategoryListItems(context, categories),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => _buildErrorTile(err),
    );
  }

  /// カテゴリーリストアイテムを構築
  Widget _buildCategoryListItems(
    BuildContext context,
    List<dynamic> categories,
  ) {
    if (categories.isEmpty) {
      return const ListTile(title: Text('カテゴリーなし'));
    }

    return Column(
      children: [
        for (var cat in categories)
          ListTile(
            title: Text(cat['name'] ?? ''),
            leading: const Icon(Icons.label_outline),
            onTap: () => _handleCategoryTap(context, cat),
          ),
      ],
    );
  }

  /// カテゴリータップ時の処理
  void _handleCategoryTap(BuildContext context, Map<String, dynamic> cat) {
    Navigator.pop(context); // Drawerを閉じる

    if (onCategorySelected != null && cat['id'] != null) {
      final categoryId = cat['id'] is int
          ? cat['id'] as int
          : int.tryParse(cat['id'].toString());

      if (categoryId != null) {
        onCategorySelected!(categoryId, cat['name'] ?? '');
      }
    }
  }

  /// エラー表示用のタイルを構築
  Widget _buildErrorTile(Object error) {
    return ListTile(
      title: const Text('カテゴリー取得エラー'),
      subtitle: Text(error.toString()),
    );
  }
}

// ============================================================================
// AppBar関連
// ============================================================================

/// アプリ共通のAppBarを生成する関数
///
/// [context]: ビルドコンテキスト
/// [title]: タイトル文字列
/// [userModel]: ユーザー情報（ログイン済みの場合に利用）
/// [onSearchPressed]: 検索ボタン押下時のコールバック（現在は未使用）
///
/// 戻り値: 設定済みのAppBarウィジェット
AppBar buildAppBar(
  BuildContext context,
  String title,
  UserModel? userModel, {
  VoidCallback? onSearchPressed,
}) {
  return AppBar(
    title: _AppBarTitle(title: title),
    centerTitle: true,
    actions: [
      Align(
        alignment: Alignment.centerLeft,
        child: _UserAction(userModel: userModel, context: context),
      ),
      _CartAction(context: context),
    ],
    elevation: _appBarElevation,
    backgroundColor: _appBarBackgroundColor,
  );
}

/// AppBarのタイトル部分ウィジェット
class _AppBarTitle extends StatelessWidget {
  final String title;
  const _AppBarTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: _appBarTitleFontSize,
        color: _appBarTitleColor,
      ),
    );
  }
}

// ============================================================================
// ユーザーアクション関連
// ============================================================================

/// ユーザー用アクション部分（ログイン状態で表示を切替）
///
/// ログインしていない場合はログインボタンを表示し、
/// ログイン済みの場合はメニューボタンを表示します。
class _UserAction extends ConsumerWidget {
  final UserModel? userModel;
  final BuildContext context;
  const _UserAction({required this.userModel, required this.context});

  @override
  Widget build(BuildContext contextWidget, WidgetRef ref) {
    if (userModel == null) {
      return _buildLoginButton();
    }
    return _buildUserMenu(ref);
  }

  /// ログインボタンを構築
  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () => Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (context) => const Login())),
      child: const Text('ログイン'),
    );
  }

  /// ユーザーメニューを構築
  Widget _buildUserMenu(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuSelection(value, ref),
          itemBuilder: (context) => _buildMenuItems(),
          child: _buildMenuButton(),
        ),
      ),
    );
  }

  /// メニューアイテムを構築
  List<PopupMenuItem<String>> _buildMenuItems() {
    return const [
      PopupMenuItem<String>(value: 'purchaseHistory', child: Text('購入履歴')),
      PopupMenuItem<String>(value: 'userSetting', child: Text('ユーザー設定')),
      PopupMenuItem<String>(value: 'changePassword', child: Text('パスワード変更')),
      PopupMenuItem<String>(value: 'logout', child: Text('ログアウト')),
    ];
  }

  /// メニューボタンを構築
  Widget _buildMenuButton() {
    return Row(
      children: [
        Text(
          '購入履歴・設定',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Icon(Icons.arrow_drop_down, color: Colors.white),
      ],
    );
  }

  /// メニュー選択時の処理
  void _handleMenuSelection(String value, WidgetRef ref) {
    switch (value) {
      case 'purchaseHistory':
        _navigateToPurchaseHistory();
        break;
      case 'userSetting':
        _navigateToUserSetting();
        break;
      case 'changePassword':
        _navigateToPasswordChange();
        break;
      case 'logout':
        _showLogoutDialog(ref);
        break;
    }
  }

  /// 購入履歴画面へ遷移
  void _navigateToPurchaseHistory() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (context) => const PurchaseHistory()));
  }

  /// ユーザー設定画面へ遷移
  void _navigateToUserSetting() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (context) => const UserSetting()));
  }

  /// パスワード変更画面へ遷移
  void _navigateToPasswordChange() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (context) => const PasswordChange()));
  }

  /// ログアウト確認ダイアログを表示
  void _showLogoutDialog(WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => _performLogout(ref),
            child: const Text('ログアウト', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// ログアウト処理を実行
  void _performLogout(WidgetRef ref) {
    ref.read(userModelProvider.notifier).state = null;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ログアウトしました')));
    Navigator.pop(context);
  }
}

// ============================================================================
// カートアクション
// ============================================================================

/// カートアイコンアクション（画面遷移ボタン）
///
/// AppBarに表示されるカートアイコンボタンです。
/// タップするとカート画面へ遷移します。
class _CartAction extends StatelessWidget {
  final BuildContext context;
  const _CartAction({required this.context});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.shopping_cart),
      onPressed: () => _navigateToCart(),
      tooltip: 'Cartページへ',
    );
  }

  /// カート画面へ遷移
  void _navigateToCart() {
    Navigator.of(
      this.context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (context) => const Cart()));
  }
}
