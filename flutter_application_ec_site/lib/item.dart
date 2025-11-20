
import 'package:flutter/material.dart';
import 'myApiProvider.dart';

/// 商品リストを表示するウィジェット
class ItemList extends StatelessWidget {
  final List<dynamic> items;

  const ItemList({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ListView.separated で商品ごとの区切り線を表示
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4), // 商品ごとの間隔
      itemBuilder: (context, index) => ItemCard(item: items[index]), // 1商品につきItemCard表示
    );
  }
}

/// 商品1件の情報カード
class ItemCard extends StatelessWidget {
  final dynamic item;

  const ItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);

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
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品画像部分
            ItemImage(imageUrl: imageUrl),
            const SizedBox(width: 12),
            // 商品の詳細情報
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
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

