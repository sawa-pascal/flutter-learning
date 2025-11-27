import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/categories/categoriesDetail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';
import 'itemsEdit.dart';
import 'package:intl/intl.dart';

class ItemsDetailPage extends ConsumerWidget {
  final Map<String, dynamic> item;

  const ItemsDetailPage({Key? key, required this.item}) : super(key: key);

  String _formatNumber(dynamic value) {
    if (value == null) return '';
    final formatter = NumberFormat("#,###");
    if (value is num) return formatter.format(value);
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return formatter.format(parsed);
      return value;
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider());

    return Scaffold(
      appBar: AppBar(title: const Text('商品詳細'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: categoriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('エラーが発生しました: $error')),
                  data: (categories) {
                    // カテゴリー名取得
                    String categoryName = '';
                    if (categories is List && item['category_id'] != null) {
                      var cat = categories.firstWhere(
                        (c) =>
                            c['id'].toString() ==
                            item['category_id'].toString(),
                        orElse: () => null,
                      );
                      categoryName = cat != null
                          ? (cat['name']?.toString() ?? '')
                          : '';
                    }
                    final description = item['description']?.toString() ?? '';
                    final imageUrl =
                        imageBaseUrl +
                        ((item['image_url'] as String?)?.trim() ?? '');
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '商品詳細',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _row('ID', _formatNumber(item['id'])),
                          const SizedBox(height: 14),
                          _row('名前', item['name']?.toString() ?? ''),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'カテゴリー',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    bool isPressed = false;
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(6),
                                      onTap: () {
                                        setState(() => isPressed = false);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => CategoriesDetailPage(
                                              categoryId: item['category_id'],
                                            ),
                                          ),
                                        );
                                      },
                                      onHighlightChanged: (v) => setState(() => isPressed = v),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isPressed
                                              ? Colors.blue.withOpacity(0.18)
                                              : Colors.blue.withOpacity(0),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          categoryName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _row(
                            '価格',
                            item['price'] != null ? '¥${_formatNumber(item['price'])}' : '',
                          ),
                          const SizedBox(height: 14),
                          _row('在庫', _formatNumber(item['quantity'])),
                          const SizedBox(height: 20),
                          if (description.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '説明',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  description,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          if (imageUrl.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '画像',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      height: 180,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              height: 180,
                                              width: 180,
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('編集'),
                                onPressed: () async {
                                  final result = await Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ItemsEditPage(item: item),
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
                                        '本当にこの商品を削除しますか？この操作は元に戻せません。',
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
                                      final id = item['id'];
                                      // 削除API呼び出し
                                      final result = await ref.read(
                                        deleteItemsProvider(id: id).future,
                                      );
                                      if (result != null &&
                                          (result['success'] == true ||
                                              result['status'] == 'success')) {
                                        if (context.mounted) {
                                          Navigator.of(context).pop(true);
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('削除時にエラーが発生しました: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
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
                    );
                  },
                ),
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
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
