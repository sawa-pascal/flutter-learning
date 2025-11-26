import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/passwordChange.dart';
import 'package:flutter_application_ec_site/userSetting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'cart.dart';
import 'models/userModel/userModel.dart';
import 'purchaseHistory.dart';
import 'myApiProvider.dart';

// カテゴリーをクリックした時にホームのリストまでジャンプするID
typedef OnCategorySelected = void Function(int categoryId, String categoryName);

/// サイドメニュー（Drawer）ウィジェット
class AppDrawer extends ConsumerWidget {
  final OnCategorySelected? onCategorySelected;

  const AppDrawer({Key? key, this.onCategorySelected}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'http://3.107.37.75/images/stationery.jpeg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SizedBox.shrink(),
              ),
            ),
            // カテゴリー一覧を表示
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'カテゴリー',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return ListTile(title: Text('カテゴリーなし'));
                }

                return Column(
                  children: [
                    for (var cat in categories)
                      ListTile(
                        title: Text(cat['name'] ?? ''),
                        leading: const Icon(Icons.label_outline),
                        onTap: () {
                          Navigator.pop(context); // Drawer閉じる
                          if (onCategorySelected != null && cat['id'] != null) {
                            final categoryId = cat['id'] is int
                                ? cat['id'] as int
                                : int.tryParse(cat['id'].toString());
                            if (categoryId != null) {
                              onCategorySelected!(
                                categoryId,
                                cat['name'] ?? '',
                              );
                            }
                          }
                        },
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => ListTile(
                title: Text('カテゴリー取得エラー'),
                subtitle: Text(err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// アプリ共通のAppBarを生成する関数
/// [title]：タイトルを表示
/// [userModel]：ユーザー情報（ログイン済みの場合に利用）
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
    elevation: 10,
    backgroundColor: Colors.red,
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
      style: const TextStyle(fontSize: 30, color: Colors.green),
    );
  }
}

/// ユーザー用アクション部分（ログイン状態で表示を切替）
class _UserAction extends ConsumerWidget {
  final UserModel? userModel;
  final BuildContext context;
  const _UserAction({required this.userModel, required this.context});

  @override
  Widget build(BuildContext contextWidget, WidgetRef ref) {
    if (userModel == null) {
      return TextButton(
        onPressed: () => Navigator.of(
          context,
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: (context) => const Login())),
        child: const Text('ログイン'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'purchaseHistory') {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => const PurchaseHistory(),
                ),
              );
            } else if (value == 'userSetting') {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const UserSetting()),
              );
            } else if (value == 'changePassword') {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const PasswordChange()),
              );
            } else if (value == 'logout') {
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
                      onPressed: () {
                        ref.read(userModelProvider.notifier).state = null;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ログアウトしました')),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'ログアウト',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'purchaseHistory',
              child: Text('購入履歴'),
            ),
            const PopupMenuItem<String>(
              value: 'userSetting',
              child: Text('ユーザー設定'),
            ),
            const PopupMenuItem<String>(
              value: 'changePassword',
              child: Text('パスワード変更'),
            ),
            const PopupMenuItem<String>(value: 'logout', child: Text('ログアウト')),
          ],
          child: Row(
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
          ),
        ),
      ),
    );
  }
}

/// カートアイコンアクション（画面遷移ボタン）
class _CartAction extends StatelessWidget {
  final BuildContext context;
  const _CartAction({required this.context});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.shopping_cart),
      onPressed: () => Navigator.of(
        this.context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (context) => const Cart())),
      tooltip: 'Cartページへ',
    );
  }
}
