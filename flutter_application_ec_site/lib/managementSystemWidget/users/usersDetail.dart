import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';

class UsersDetail extends ConsumerWidget {
  final int userId;
  const UsersDetail({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersDetailAsync = ref.watch(usersListProvider(id: userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー詳細'),
      ),
      body: usersDetailAsync.when(
        data: (userMap) {
          final userList = userMap['users'] ?? [];
          if (userList.isEmpty) {
            return const Center(child: Text('ユーザー情報が見つかりません'));
          }
          final user = userList;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 32, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      '${user['name'] ?? '未設定'}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                InfoRow(label: 'ユーザーID', value: user['id']?.toString() ?? '-'),
                InfoRow(label: 'メールアドレス', value: user['email'] ?? ''),
                InfoRow(label: '電話番号', value: user['tel'] ?? ''),
                InfoRow(label: '都道府県', value: user['prefecture_id'].toString() ?? ''),
                InfoRow(label: '住所', value: user['address'] ?? ''),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('戻る'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('ユーザー情報取得エラー: $err')),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
