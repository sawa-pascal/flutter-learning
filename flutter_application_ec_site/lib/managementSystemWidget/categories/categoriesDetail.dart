import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';
import 'categoriesEdit.dart';

class CategoriesDetailPage extends ConsumerStatefulWidget {
  final int categoryId;

  const CategoriesDetailPage({Key? key, required this.categoryId}) : super(key: key);

  @override
  ConsumerState<CategoriesDetailPage> createState() => _CategoriesDetailPageState();
}

class _CategoriesDetailPageState extends ConsumerState<CategoriesDetailPage> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider());

    // カテゴリーIDに対応するカテゴリーを検索
    final categoryAsync = categoriesAsync.whenData((categories) {
      if (categories is List) {
        return categories.firstWhere(
          (cat) => cat['id'].toString() == widget.categoryId.toString(),
          orElse: () => null,
        );
      }
      return null;
    });

    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリー詳細')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: categoryAsync.when(
            data: (category) {
              if (category == null) {
                return const Center(child: Text('カテゴリー情報が見つかりません'));
              }
              return Card(
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
                                  builder: (context) => CategoriesEditPage(category: category),
                                ),
                              );
                              if (result == true) {
                                if (mounted) {
                                  // 正しくリスト画面等をリロードできるようにpop(true)
                                  Navigator.of(context).pop(true);
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete),
                            label: _deleting
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('削除'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: _deleting
                                ? null
                                : () async {
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
                                      setState(() {
                                        _deleting = true;
                                      });
                                      try {
                                        final id = category['id'];
                                        // 削除API呼び出し
                                        final result = await ref.read(
                                          deleteCategoriesProvider(id: id).future,
                                        );

                                        if (result != null &&
                                            (result['success'] == true ||
                                                result['status'] == 'success')) {
                                          if (mounted) {
                                            Navigator.of(context).pop(true);
                                          }
                                        } else {
                                          if (mounted) {
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
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('削除時にエラー: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                      if (mounted) {
                                        setState(() {
                                          _deleting = false;
                                        });
                                      }
                                    }
                                  },
                          ),
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
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('カテゴリー情報の取得に失敗しました: $err')),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
