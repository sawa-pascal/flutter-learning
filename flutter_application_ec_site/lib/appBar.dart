import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'cart.dart';
import 'models/userModel/userModel.dart';
import 'purchaseHistory.dart';
import 'myApiProvider.dart';

/// アプリ共通のAppBarを生成する関数
/// [title]：タイトルを表示
/// [userModel]：ユーザー情報（ログイン済みの場合に利用）
AppBar buildAppBar(BuildContext context, String title, UserModel? userModel) {
  return AppBar(
    // タイトルウィジェット
    title: _AppBarTitle(title: title),
    centerTitle: true, // タイトルを中央寄せ
    leading: IconButton(
      icon: const Icon(Icons.home), // 先頭に「ホーム」アイコン
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PurchaseHistory()),
        );
      },
    ),
    actions: [
      // 検索アイコン
      const Icon(Icons.search),
      // ユーザーのログイン状態によって「ログイン」ボタンかユーザー名表示
      _UserAction(userModel: userModel, context: context),
      // カートボタン
      _CartAction(context: context),
    ],
    elevation: 10, // 影の高さ
    backgroundColor: Colors.red, // AppBarの背景色
    // flexibleSpace: const _AppBarImage(), // 背景画像（画像がAppBarの下層に敷かれる）
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
      style: const TextStyle(fontSize: 30, color: Colors.green), // 大きな緑色文字
    );
  }
}

/// ユーザー用アクション部分（ログイン状態で表示を切替）
/// 未ログインなら「ログイン」ボタン／ログイン済みならユーザー名をメニューボタン化
class _UserAction extends ConsumerWidget {
  final UserModel? userModel;
  final BuildContext context;
  const _UserAction({required this.userModel, required this.context});

  @override
  Widget build(BuildContext contextWidget, WidgetRef ref) {
    if (userModel == null) {
      // 未ログイン→「ログイン」ボタン
      return TextButton(
        onPressed: () => Navigator.of(
          context,
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: (context) => const Login())),
        child: const Text('ログイン'),
      );
    }
    // ログイン済み→ユーザー名を押すとメニューを表示
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
            } else if (value == 'userInfo') {
              // Example: User Infoページがなければダイアログで代用
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ユーザー情報'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ユーザー名: ${userModel!.name}'),
                      const SizedBox(height: 4),
                      Text('メール: ${userModel!.email}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('閉じる'),
                    ),
                  ],
                ),
              );
            } else if (value == 'changePassword') {
              // パスワード変更ページ、未実装ならダイアログで案内
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('パスワード変更'),
                  content: const Text('パスワード変更ページは未実装です。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else if (value == 'logout') {
              // ログアウト処理（ユーザーモデルのリセットやAPI呼び出し等）
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
                        // Providerでユーザー情報をクリア（ログアウト処理）
                        ref.read(userModelProvider.notifier).state = null;
                        // ログアウト完了をスナックバーで通知
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ログアウトしました')),
                        );
                        Navigator.pop(context); // ダイアログ閉じる
                        // 追加：トップページ等に遷移など
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
              value: 'userInfo',
              child: Text('ユーザー情報'),
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
                userModel!.name,
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
      icon: const Icon(Icons.shopping_cart), // カートアイコン
      onPressed: () => Navigator.of(
        this.context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (context) => const Cart())),
      tooltip: 'Cartページへ',
    );
  }
}

/// AppBarの背景画像部分（flexibleSpace属性で重ねる）
class _AppBarImage extends StatelessWidget {
  const _AppBarImage();

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageBaseUrl + 'stationery.jpeg', // 指定の画像URL
      fit: BoxFit.cover, // 枠内に画像全体を収める
    );
  }
}
