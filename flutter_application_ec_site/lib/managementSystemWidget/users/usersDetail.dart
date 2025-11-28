import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/users/usersEdit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';

class UsersDetail extends ConsumerWidget {
  final int userId;
  const UsersDetail({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersDetailAsync = ref.watch(usersListProvider(id: userId));
    final prefecturesAsync = ref.watch(prefecturesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー詳細')),
      body: usersDetailAsync.when(
        data: (userMap) {
          final userList = userMap['users'] ?? [];
          if (userList.isEmpty) {
            return const Center(child: Text('ユーザー情報が見つかりません'));
          }
          final user = userList;

          // prefectures の状態で条件分岐してUI表示
          return prefecturesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('都道府県取得失敗: $err')),
            data: (prefecturesRaw) {
              // prefecturesRaw は List<dynamic>（Map型想定）
              final prefectures = (prefecturesRaw as List<dynamic>).whereType<Map<String, dynamic>>().toList();

              // ユーザーのprefecture_id で都道府県名を取得
              String? prefectureName;
              final rawPrefId = user['prefecture_id'];
              if (rawPrefId != null) {
                var idStr = rawPrefId.toString();
                var match = prefectures.firstWhere(
                  (p) => p['id'].toString() == idStr,
                  orElse: () => {},
                );
                prefectureName = match.isNotEmpty ? (match['name']?.toString() ?? '') : '';
              } else {
                prefectureName = '';
              }

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
                    InfoRow(
                      label: '都道府県',
                      value: prefectureName ?? '',
                    ),
                    InfoRow(label: '住所', value: user['address'] ?? ''),
                    const SizedBox(height: 40),
                    Center(
                      child: Wrap(
                        spacing: 20,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // 編集画面へ遷移し、戻り値で更新があればリロード
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UsersEditPage(userId: userId),
                                ),
                              );
                              // 編集後にユーザー情報を再度取得したい場合
                              if (result == true) {
                                ref.invalidate(usersListProvider(id: userId));
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('編集'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('削除の確認'),
                                  content: const Text('本当にこのユーザーを削除しますか？この操作は元に戻せません。'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('キャンセル'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('削除', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                try {
                                  final result = await ref.read(
                                    deleteUserProvider(id: userId).future,
                                  );
                                  if ((result['success'] ?? false) == true) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('ユーザーを削除しました')),
                                      );
                                    }
                                    Navigator.of(context).pop(); // 一覧などへ戻る
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(result['message'] ?? '削除に失敗しました')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('削除時にエラーが発生しました: $e')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('削除'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('戻る'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('ユーザー情報取得エラー: $err')),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
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
