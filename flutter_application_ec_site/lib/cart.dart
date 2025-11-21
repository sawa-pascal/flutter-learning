import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/models/cartItemModel/cartItemModel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'myApiProvider.dart';
import 'purchase.dart';

class Cart extends ConsumerStatefulWidget {
  const Cart({super.key});

  @override
  ConsumerState<Cart> createState() => CartState();
}

class CartState extends ConsumerState<Cart> {
  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cartItems.isEmpty
          ? const Center(child: Text('カートは空です'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: item.image_url.isNotEmpty
                      ? Image.network(
                          imageBaseUrl + item.image_url,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        )
                      : const Icon(Icons.image_outlined),
                  title: Text(item.name),
                  subtitle: Text('¥${item.price} x ${item.quantity}'),
                  trailing: Text('合計: ¥${item.price * item.quantity}'),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const PurchasePage()));
        },
        icon: const Icon(Icons.shopping_bag),
        label: const Text('購入する'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
