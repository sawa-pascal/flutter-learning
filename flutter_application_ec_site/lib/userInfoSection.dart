import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/userModel/userModel.dart';

// ユーザー情報セクションウィジェット
class UserInfoSection extends ConsumerWidget {
  final UserModel? userModel;

  const UserInfoSection({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ユーザー未ログイン時はスペースのみ表示
    if (userModel == null) {
      return const SizedBox(height: 20);
    }
    // ユーザー情報カード
    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: const [
            _UserIcon(), // アイコン部分
            SizedBox(width: 10),
            Expanded(child: _UserDetailColumn()), // ユーザー詳細部分
          ],
        ),
      ),
    );
  }
}

// ユーザーアイコン部分のウィジェット
class _UserIcon extends StatelessWidget {
  const _UserIcon();

  @override
  Widget build(BuildContext context) {
    // グリーン色のアカウントアイコンを表示
    return const Icon(Icons.account_circle, size: 36, color: Colors.green);
  }
}

// ユーザー詳細情報を表示するウィジェット
class _UserDetailColumn extends ConsumerWidget {
  const _UserDetailColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerから最新のユーザーモデルを取得
    final userModel = (ref.watch(userModelProvider));
    if (userModel == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ユーザー名（強調表示）
        Text(
          userModel.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 2),
        // メールアドレス
        Text(
          userModel.email,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        // 電話番号
        Text(
          'TEL: ${userModel.tel}',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        // 住所（空欄でなければ表示）
        if (userModel.address != null && userModel.address!.trim().isNotEmpty)
          Text(
            '住所: ${userModel.address}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        const SizedBox(height: 6),
        // ログアウトボタン
        const _LogoutButton(),
      ],
    );
  }
}

// ログアウトボタンのウィジェット
class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.red, size: 18), // ログアウトアイコン
        label: const Text('ログアウト', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          minimumSize: const Size(80, 36),
        ),
        onPressed: () {
          // Providerでユーザー情報をクリア（ログアウト処理）
          ref.read(userModelProvider.notifier).state = null;
          // ログアウト完了をスナックバーで通知
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ログアウトしました')));
        },
      ),
    );
  }
}
