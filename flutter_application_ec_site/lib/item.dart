import 'package:flutter/material.dart';
import 'myApiProvider.dart';
// カテゴリー一覧取得用Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

// カートモデル等をインポート
import 'models/cartItemModel/cartItemModel.dart';

import 'utility.dart';

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
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
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
class ItemCard extends ConsumerWidget {
  final dynamic item;

  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画像URL、商品名、価格、説明、在庫数を取り出す
    final imageUrl = _extractImageUrl(item);
    final name = item['name']?.toString() ?? '名称不明';
    final price = _formatPrice(item['price']);
    final description = item['description']?.toString();

    // 在庫数取得＆0なら売り切れ表示
    final int? quantity = item['quantity'] is int
        ? item['quantity']
        : int.tryParse(item['quantity'].toString());
    final bool isSoldOut = (quantity ?? 0) == 0;
    final stock = _formatStock(item['quantity'], showSoldOut: true);

    return Stack(
      children: [
        Opacity(
          opacity: isSoldOut ? 0.6 : 1.0,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            elevation: 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: isSoldOut
                  ? null
                  : () => _showItemDetailDialog(
                        context,
                        ref,
                        item,
                        name,
                        imageUrl,
                        price,
                        description,
                        stock,
                      ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // サムネイル画像
                    ItemImage(imageUrl: imageUrl, isSoldOut: isSoldOut),
                    const SizedBox(width: 12),
                    // 商品情報詳細
                    Expanded(
                      child: _ItemDetails(
                        name: name,
                        price: price,
                        description: description,
                        stock: stock,
                        isSoldOut: isSoldOut,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isSoldOut)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.90),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Text(
                    '売り切れ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 1.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _changeQuantity({
    required ValueNotifier<int> quantityNotifier,
    required int delta,
    required int stock,
  }) {
    quantityNotifier.value = (quantityNotifier.value + delta).clamp(1, stock);
  }

  /// 商品拡大表示ダイアログを表示（数量指定対応版）
  void _showItemDetailDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic item,
    String name,
    String? imageUrl,
    String? price,
    String? description,
    String? stock,
  ) {
    // ダイアログで使う数量管理用 ValueNotifier
    final quantityNotifier = ValueNotifier<int>(1);
    final int maxStock = (item['quantity'] is int)
        ? item['quantity']
        : int.tryParse(item['quantity'].toString()) ?? 0;

    final bool isSoldOut = maxStock == 0;

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
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
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
                          // 在庫数
                          if (stock != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 6.0,
                                bottom: 6.0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.inventory_2,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSoldOut ? "売り切れ" : stock,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSoldOut ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          // 商品説明
                          if (description != null &&
                              description.trim().isNotEmpty)
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              const Text('選択数: '),
                              GestureDetector(
                                onLongPressStart: (!isSoldOut && quantityNotifier.value > 1)
                                    ? (_) {
                                        startLongPressRepeater(() {
                                          if (quantityNotifier.value > 1) {
                                            setState(() {
                                              _changeQuantity(
                                                quantityNotifier:
                                                    quantityNotifier,
                                                delta: -1,
                                                stock: maxStock,
                                              );
                                            });
                                          }
                                        });
                                      }
                                    : null,
                                onLongPressEnd: (_) => stopLongPressRepeater(),
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: (!isSoldOut && quantityNotifier.value > 1)
                                      ? () {
                                          setState(() {
                                            _changeQuantity(
                                              quantityNotifier:
                                                  quantityNotifier,
                                              delta: -1,
                                              stock: maxStock,
                                            );
                                          });
                                        }
                                      : null,
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: quantityNotifier,
                                builder: (context, value, _) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$value',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              GestureDetector(
                                onLongPressStart:
                                    (!isSoldOut && quantityNotifier.value < maxStock)
                                    ? (_) {
                                        startLongPressRepeater(() {
                                          if (quantityNotifier.value <
                                              maxStock) {
                                            setState(() {
                                              _changeQuantity(
                                                quantityNotifier:
                                                    quantityNotifier,
                                                delta: 1,
                                                stock: maxStock,
                                              );
                                            });
                                          }
                                        });
                                      }
                                    : null,
                                onLongPressEnd: (_) => stopLongPressRepeater(),
                                child: IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: (!isSoldOut && quantityNotifier.value < maxStock)
                                      ? () {
                                          setState(() {
                                            _changeQuantity(
                                              quantityNotifier:
                                                  quantityNotifier,
                                              delta: 1,
                                              stock: maxStock,
                                            );
                                          });
                                        }
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // カートへ追加ボタン
                          Align(
                            alignment: Alignment.centerRight,
                            child: Consumer(
                              builder: (context, ref, _) {
                                return ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isSoldOut ? Colors.grey : Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                  ),
                                  label: Text(isSoldOut ? '売り切れ' : 'カートへ追加'),
                                  onPressed: isSoldOut
                                      ? null
                                      : () {
                                          final quantityToAdd = quantityNotifier.value;
                                          if (maxStock != 0 &&
                                              quantityToAdd > maxStock) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('在庫数を超えています'),
                                              ),
                                            );
                                            return;
                                          }

                                          // ここでcartItemsProviderへ追加
                                          final cartItem = CartItemModel(
                                            id: item['id'] is int
                                                ? item['id']
                                                : int.tryParse(
                                                        item['id'].toString(),
                                                      ) ??
                                                    0,
                                            name: item['name'] ?? "",
                                            price: item['price'] is int
                                                ? item['price']
                                                : int.tryParse(
                                                        item['price'].toString(),
                                                      ) ??
                                                    0,
                                            stock: item['quantity'] is int
                                                ? item['quantity']
                                                : int.tryParse(
                                                        item['quantity']
                                                            .toString(),
                                                      ) ??
                                                    0,
                                            quantity: quantityToAdd,
                                            image_url: item['image_url']?.toString() ?? "",
                                          );

                                          final cartItems = ref.read(
                                            cartItemsProvider,
                                          );

                                          // 既に同じidの商品があればquantityだけ増やす
                                          final existingIndex =
                                              cartItems.indexWhere(
                                            (ci) => ci.id == cartItem.id,
                                          );
                                          if (existingIndex != -1) {
                                            final updatedCartItems = [...cartItems];
                                            final existingItem =
                                                updatedCartItems[existingIndex];
                                            final newQuantity =
                                                existingItem.quantity +
                                                    quantityToAdd;
                                            // 在庫超えるかどうかチェック
                                            if (maxStock != 0 &&
                                                newQuantity > maxStock) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'カートにすでに ${existingItem.quantity} 個あり、合わせると在庫数 $maxStock を超える数量です',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            updatedCartItems[existingIndex] =
                                                existingItem.copyWith(
                                              quantity: newQuantity,
                                            );
                                            ref
                                                .read(
                                                    cartItemsProvider.notifier)
                                                .state = updatedCartItems;
                                          } else {
                                            ref
                                                .read(
                                                    cartItemsProvider.notifier)
                                                .state = [
                                              ...cartItems,
                                              cartItem,
                                            ];
                                          }

                                          Navigator.of(context).pop();

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'カートに${quantityToAdd}個追加しました',
                                              ),
                                            ),
                                          );
                                        },
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
                      );
                    },
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

  /// 在庫数をフォーマットする（在庫数：5 など）。0の場合"売り切れ"とする（showSoldOutがtrueの場合）
  String? _formatStock(dynamic stock, {bool showSoldOut = false}) {
    if (stock == null) return null;
    int? stockInt;
    if (stock is int) {
      stockInt = stock;
    } else if (stock is String) {
      stockInt = int.tryParse(stock);
    }
    if (stockInt != null) {
      if (showSoldOut && stockInt == 0) {
        return '売り切れ';
      }
      return '在庫数: $stockInt';
    }
    // パースできなかった場合はそのまま表示
    return showSoldOut && (stock == "0" || stock == 0)
        ? '売り切れ'
        : '在庫数: $stock';
  }
}

/// 商品詳細（名前・値段・説明文、在庫数）部分ウィジェット
class _ItemDetails extends StatelessWidget {
  final String name;
  final String? price;
  final String? description;
  final String? stock;
  final bool isSoldOut;

  const _ItemDetails({
    Key? key,
    required this.name,
    this.price,
    this.description,
    this.stock,
    this.isSoldOut = false,
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
        // 在庫数または売り切れ表示
        if (stock != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.inventory_2, size: 16, color: isSoldOut ? Colors.red : Colors.grey),
              const SizedBox(width: 4),
              Text(
                isSoldOut ? '売り切れ' : stock!,
                style: TextStyle(
                  fontSize: 14,
                  color: isSoldOut ? Colors.red : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
  final bool isSoldOut;

  const ItemImage({Key? key, this.imageUrl, this.isSoldOut = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 画像URLがなければデフォルトアイコンを表示
    if (imageUrl == null) {
      return const Icon(Icons.image);
    }
    // 画像表示（読み込み失敗時はアイコン表示）
    return Stack(
      children: [
        ClipRRect(
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
                color: isSoldOut ? Colors.grey[400] : null,
                colorBlendMode: isSoldOut ? BlendMode.modulate : null,
              ),
            ),
          ),
        ),
        if (isSoldOut)
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}
