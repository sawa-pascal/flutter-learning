import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/cartItemModel/cartItemModel.dart';
import 'myApiProvider.dart';

class PurchasePage extends ConsumerWidget {
  const PurchasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);

    int totalPrice = cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('購入確認')),
      body: cartItems.isEmpty
          ? const Center(child: Text('カートに商品がありません'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: item.image_url.isNotEmpty
                            ? Image.network(
                                imageBaseUrl + item.image_url,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              )
                            : const Icon(Icons.image_outlined),
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('価格: ¥${item.price}'),
                            Text('選択数: ${item.quantity}'),
                          ],
                        ),
                        trailing: Text('小計: ¥${item.price * item.quantity}'),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      const Text(
                        '合計金額: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '¥$totalPrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: 購入処理を書く
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('購入処理は未実装です')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.shopping_bag),
                        label: const Text('購入する'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
