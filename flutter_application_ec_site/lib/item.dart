import 'package:flutter/material.dart';
import 'myApiProvider.dart';
// カテゴリー一覧取得用Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 商品リストを表示するウィジェット
class ItemList extends ConsumerWidget {
  final List<dynamic> items;
  const ItemList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    // FutureBuilder的にAsyncValueを分岐して使う
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('カテゴリー取得失敗: $error')),
      data: (categories) {
        // 商品をカテゴリーごとにグループ化: Map<category_id, List<item>>
        final Map<String, List<dynamic>> itemsByCategory = {};
        for (final item in items) {
          final cid = item['category_id']?.toString() ?? '0';
          itemsByCategory.putIfAbsent(cid, () => []).add(item);
        }

        // カテゴリーorder順でソートしたカテゴリーリスト
        final sortedCategories = List<Map<String, dynamic>>.from(categories);
        sortedCategories.sort((a, b) {
          final ao = int.tryParse(a['order'].toString()) ?? 9999;
          final bo = int.tryParse(b['order'].toString()) ?? 9999;
          return ao.compareTo(bo);
        });

        // 表示用: 各カテゴリーのセクション(header＋商品リスト)
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: sortedCategories.length,

          separatorBuilder: (context, index) => const Divider(
            height: 0,
            thickness: 2,
            indent: 0,
            endIndent: 0,
            color: Colors.grey,
          ),
          itemBuilder: (context, catIndex) {
            final category = sortedCategories[catIndex];
            final categoryId = category['id'].toString();
            final categoryName = category['name']?.toString() ?? '未分類';
            final categoryItems = itemsByCategory[categoryId] ?? [];

            if (categoryItems.isEmpty) {
              // このカテゴリに商品が無ければセクションをスキップ
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // カテゴリー名
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 4),
                    itemBuilder: (context, index) =>
                        ItemCard(item: categoryItems[index]),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// 商品1件の情報カード
class ItemCard extends StatelessWidget {
  final dynamic item;

  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 画像URL、商品名、価格、説明を取り出す
    final imageUrl = _extractImageUrl(item);
    final name = item['name']?.toString() ?? '名称不明';
    final price = _formatPrice(item['price']);
    final description = item['description']?.toString();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () =>
            _showItemDetailDialog(context, name, imageUrl, price, description),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // サムネイル画像
              ItemImage(imageUrl: imageUrl),
              const SizedBox(width: 12),
              // 商品情報詳細
              Expanded(
                child: _ItemDetails(
                  name: name,
                  price: price,
                  description: description,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 商品拡大表示ダイアログを表示
  void _showItemDetailDialog(
    BuildContext context,
    String name,
    String? imageUrl,
    String? price,
    String? description,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 拡大画像
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            height: 180,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // 商品名
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 価格
                      if (price != null)
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 14),
                      // 商品説明
                      if (description != null && description.trim().isNotEmpty)
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      const SizedBox(height: 20),

                      // カートへ追加ボタン
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text('カートへ追加'),
                          onPressed: () {
                            // TODO: カート追加処理を実装
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('カートに追加しました')),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),
                      // 閉じるボタン
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('閉じる'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  /// 画像URL生成関数（APIからのパスとベースURLを連結）
  String? _extractImageUrl(dynamic item) {
    final url = item['image_url'];
    if (url == null) return null;
    return '$imageBaseUrl$url';
  }

  /// 価格を「¥1,234」のような形式に変換する
  String? _formatPrice(dynamic price) {
    if (price == null) return null;
    int? priceInt;
    if (price is int) {
      priceInt = price;
    } else if (price is String) {
      priceInt = int.tryParse(price);
    }
    if (priceInt != null) {
      // カンマ区切り（千の位ごとにカンマ）で表示
      return '¥${priceInt.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ",")}';
    }
    // パースできなかった場合はそのまま表示
    return '¥$price';
  }
}

/// 商品詳細（名前・値段・説明文）部分ウィジェット
class _ItemDetails extends StatelessWidget {
  final String name;
  final String? price;
  final String? description;

  const _ItemDetails({
    Key? key,
    required this.name,
    this.price,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 商品名
        Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // 価格（存在する場合）
        if (price != null) ...[
          const SizedBox(height: 8),
          Text(
            price!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 0),
                  blurRadius: 1.5,
                ),
              ],
            ),
          ),
        ],
        // 説明文（空でない場合）
        if (description != null && description!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ],
    );
  }
}

/// 商品画像表示用ウィジェット
class ItemImage extends StatelessWidget {
  final String? imageUrl;

  const ItemImage({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 画像URLがなければデフォルトアイコンを表示
    if (imageUrl == null) {
      return const Icon(Icons.image);
    }
    // 画像表示（読み込み失敗時はアイコン表示）
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 56,
        height: 56,
        color: Colors.grey[300],
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.network(
            imageUrl!,
            errorBuilder: (context, error, stackTrace) {
              // 画像エラーのときはアイコン
              debugPrint("Image load error: $error, stack: $stackTrace");
              return const Icon(Icons.image_not_supported);
            },
          ),
        ),
      ),
    );
  }
}
