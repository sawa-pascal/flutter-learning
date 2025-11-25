
import 'package:flutter/material.dart';
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
    flexibleSpace: const _AppBarImage(), // 背景画像（画像がAppBarの下層に敷かれる）
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
/// 未ログインなら「ログイン」ボタン／ログイン済みならユーザー名を表示
class _UserAction extends StatelessWidget {
  final UserModel? userModel;
  final BuildContext context;
  const _UserAction({required this.userModel, required this.context});

  @override
  Widget build(BuildContext context) {
    if (userModel == null) {
      // 未ログイン→「ログイン」ボタン
      return TextButton(
        onPressed: () => Navigator.of(
          this.context, // ※親のcontextを使うことでダイアログ等にも対応
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: (context) => const Login())),
        child: const Text('ログイン'),
      );
    }
    // ログイン済み→ユーザー名表示
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Text(
          userModel!.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
      imageBaseUrl + '%E3%83%8E%E3%83%BC%E3%83%88/1129031014690ad52f20b671.42419074.png', // 指定の画像URL
      fit: BoxFit.contain, // 枠内に画像全体を収める
    );
  }
}

