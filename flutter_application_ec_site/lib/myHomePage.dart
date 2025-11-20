import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'test.dart';
import 'login.dart';
import 'cart.dart';
import 'myApiProvider.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          error: error,
          onRetry: () => ref.refresh(itemsProvider.future),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(itemsProvider);
            // Wait for refresh effect
            await ref.read(itemsProvider.future);
          },
          child: _ItemList(items: items),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 30, color: Colors.green),
      ),
      centerTitle: true,
      leading: const Icon(Icons.home),
      actions: [
        const Icon(Icons.search),
        TextButton(
          onPressed: () => Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: (context) => const Login())),
          child: const Text('ログイン'),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: (context) => const Cart())),
          tooltip: 'Cartページへ',
        ),
      ],
      elevation: 10,
      backgroundColor: Colors.red,
      flexibleSpace: Image.network(
        'http://3.26.29.114/images/%E3%83%8E%E3%83%BC%E3%83%88/1129031014690ad52f20b671.42419074.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
    Key? key,
  }) : super(key: key);

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 40),
          const SizedBox(height: 16),
          Text(
            error.toString().isNotEmpty
                ? error.toString()
                : 'エラーが発生しました',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('再試行'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const Test()),
              );
            },
            child: const Text('Testページへ'),
          ),
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({required this.items, Key? key}) : super(key: key);

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemCard(item: item);
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, Key? key}) : super(key: key);

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
            _ItemImage(imageUrl: imageUrl),
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

class _ItemImage extends StatelessWidget {
  final String? imageUrl;
  const _ItemImage({this.imageUrl});

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
