
import 'package:flutter/material.dart';
import 'myApiProvider.dart'; // imageBaseUrlを使うため

class ItemList extends StatelessWidget {
  const ItemList({required this.items, Key? key}) : super(key: key);

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemCard(item: item);
      },
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({required this.item, Key? key}) : super(key: key);

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = item['image_url'] != null
        ? '$imageBaseUrl${item['image_url']}'
        : null;
    final String name = item['name']?.toString() ?? '名称不明';
    final String? formattedPrice = _formatPrice(item['price']);
    final String? description = item['description']?.toString();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItemImage(imageUrl: imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (formattedPrice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      formattedPrice,
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
                  if (description != null && description.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatPrice(dynamic price) {
    if (price == null) return null;
    int? priceInt;
    if (price is int) {
      priceInt = price;
    } else if (price is String) {
      priceInt = int.tryParse(price);
    }
    if (priceInt != null) {
      final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
      String priceStr =
          priceInt.toString().replaceAllMapped(reg, (match) => ',');
      return '¥$priceStr';
    } else {
      return '¥$price';
    }
  }
}

class ItemImage extends StatelessWidget {
  final String? imageUrl;
  const ItemImage({this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const Icon(Icons.image);
    }
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
              debugPrint("Image load error: $error, stack: $stackTrace");
              return const Icon(Icons.image_not_supported);
            },
          ),
        ),
      ),
    );
  }
}
