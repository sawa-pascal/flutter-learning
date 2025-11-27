import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';
import 'categoriesEdit.dart';

class CategoriesDetailPage extends ConsumerWidget {
  final Map<String, dynamic> category;

  const CategoriesDetailPage({Key? key, required this.category})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリー詳細')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'カテゴリー詳細',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _row('ID', category['id']?.toString() ?? ''),
                  const SizedBox(height: 14),
                  _row('名前', category['name']?.toString() ?? ''),
                  const SizedBox(height: 14),
                  _row('表示順', category['display_order']?.toString() ?? ''),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('編集'),
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  CategoriesEditPage(category: category),
                            ),
                          );
                          if (result == true) {
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('削除'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('削除の確認'),
                              content: const Text(
                                '本当にこのカテゴリーを削除しますか？この操作は元に戻せません。',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('キャンセル'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('削除'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              final id = category['id'];
                              // 削除API呼び出し
                              final result = await ref.read(
                                deleteCategoriesProvider(id: id).future,
                              );

                              if (result != null &&
                                  (result['success'] == true ||
                                      result['status'] == 'success')) {
                                if (context.mounted) {
                                  Navigator.of(context).pop(true);
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '削除に失敗しました: ${result?['message'] ?? '不明なエラー'}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('削除時にエラー: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                      // 編集ボタン、削除ボタン等を追加したい場合はここで
                    ],
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('一覧に戻る'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
