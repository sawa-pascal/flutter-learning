import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/models/cartItemModel/cartItemModel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'login.dart';
import 'myApiProvider.dart';
import 'purchase.dart';
import 'models/userModel/userModel.dart';
import 'utility.dart';

class Cart extends ConsumerStatefulWidget {
  const Cart({super.key});

  @override
  ConsumerState<Cart> createState() => CartState();
}

class CartState extends ConsumerState<Cart> {
  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartItemsProvider);
    final cartItemsNotifier = ref.read(cartItemsProvider.notifier);
    final user = ref.watch(userModelProvider);

    int totalPrice = cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('カート')),
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
                      final int subTotal = item.price * item.quantity;
                      final int taxedSubTotal = (subTotal * 1.1).round();

                      // ListTileの部分をRowを使ってwrapし、Overflow対策
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 8,
                              ),
                              child: item.image_url.isNotEmpty
                                  ? Image.network(
                                      imageBaseUrl + item.image_url,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    )
                                  : const Icon(Icons.image_outlined, size: 50),
                            ),
                            // Expanded Title/Sub/Controls
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text('価格: ¥${formatYen(item.price)}'),
                                  // 選択数: 数変更可能UI (Wrapを使って対策)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        const Text('選択数: '),
                                        GestureDetector(
                                          onLongPressStart: item.quantity > 1
                                              ? (_) {
                                                  startLongPressRepeater(() {
                                                    if (item.quantity > 1) {
                                                      cartItemsNotifier
                                                          .state = [
                                                        for (final cartItem
                                                            in cartItemsNotifier
                                                                .state)
                                                          if ((cartItem.id ==
                                                                  item.id) &&
                                                              cartItem.quantity >
                                                                  1)
                                                            cartItem.copyWith(
                                                              quantity:
                                                                  cartItem
                                                                      .quantity -
                                                                  1,
                                                            )
                                                          else
                                                            cartItem,
                                                      ];
                                                    }
                                                  });
                                                }
                                              : null,
                                          onLongPressEnd: (_) =>
                                              stopLongPressRepeater(),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            onPressed: item.quantity > 1
                                                ? () {
                                                    cartItemsNotifier.state = [
                                                      for (final cartItem
                                                          in cartItemsNotifier
                                                              .state)
                                                        if ((cartItem.id ==
                                                                item.id) &&
                                                            (cartItem.quantity <
                                                                cartItem.stock))
                                                          cartItem.copyWith(
                                                            quantity:
                                                                item.quantity -
                                                                1,
                                                          )
                                                        else
                                                          cartItem,
                                                    ];
                                                  }
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        GestureDetector(
                                          onLongPressStart:
                                              item.quantity < item.stock
                                              ? (_) {
                                                  startLongPressRepeater(() {
                                                    if (item.quantity <
                                                        item.stock) {
                                                      cartItemsNotifier
                                                          .state = [
                                                        for (final cartItem
                                                            in cartItemsNotifier
                                                                .state)
                                                          if ((cartItem.id ==
                                                                  item.id) &&
                                                              (cartItem
                                                                      .quantity <
                                                                  cartItem
                                                                      .stock))
                                                            cartItem.copyWith(
                                                              quantity:
                                                                  cartItem
                                                                      .quantity +
                                                                  1,
                                                            )
                                                          else
                                                            cartItem,
                                                      ];
                                                    }
                                                  });
                                                }
                                              : null,
                                          onLongPressEnd: (_) =>
                                              stopLongPressRepeater(),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                            onPressed:
                                                item.quantity < item.stock
                                                ? () {
                                                    cartItemsNotifier.state = [
                                                      for (final cartItem
                                                          in cartItemsNotifier
                                                              .state)
                                                        if (cartItem.id ==
                                                            item.id)
                                                          cartItem.copyWith(
                                                            quantity:
                                                                item.quantity +
                                                                1,
                                                          )
                                                        else
                                                          cartItem,
                                                    ];
                                                  }
                                                : null,
                                          ),
                                        ),
                                        // 削除ボタン追加
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          tooltip: '削除',
                                          onPressed: () {
                                            cartItemsNotifier.state = [
                                              for (final cartItem
                                                  in cartItemsNotifier.state)
                                                if (cartItem.id != item.id)
                                                  cartItem,
                                            ];
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Trailing (小計/税込み)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 6,
                                right: 10,
                                top: 3,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '小計: ¥${formatYen(subTotal)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '税込み: ¥${formatYen(taxedSubTotal)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '税込み合計',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        //overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 18),
                      Text(
                        '¥${formatYen((totalPrice * 1.1).round())}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.deepOrange,
                        ),
                        //overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (user == null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PurchasePage(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text('購入する'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
