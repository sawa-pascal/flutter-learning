import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/cartItemModel/cartItemModel.dart';
import 'models/userModel/userModel.dart';
import 'myApiProvider.dart';
import 'utility.dart';

class PurchasePage extends ConsumerStatefulWidget {
  const PurchasePage({Key? key}) : super(key: key);

  @override
  ConsumerState<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends ConsumerState<PurchasePage> {
  int? selectedPaymentId;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartItemsProvider);
    final userModel = ref.watch(userModelProvider);
    final paymentsAsync = ref.watch(paymentsProvider);

    int totalPrice = cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    // (例) 10% 消費税
    int taxPrice = (totalPrice * 0.1).round();
    int totalWithTax = totalPrice + taxPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('購入確認')),
      body: cartItems.isEmpty
          ? const Center(child: Text('カートに商品がありません'))
          : ListView(
              padding: const EdgeInsets.all(0),
              children: [
                const SizedBox(height: 12),
                // 商品一覧
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'ご注文商品',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                          Text('価格: ¥${formatYen(item.price)}'),
                          Text('選択数: ${item.quantity}'),
                        ],
                      ),
                      trailing: Text(
                        '小計: ¥${formatYen(item.price * item.quantity)}',
                      ),
                    );
                  },
                ),
                const Divider(height: 32, thickness: 2),
                // 金額情報
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _priceLine('商品合計', totalPrice),
                      _priceLine('消費税 (10%)', taxPrice),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            '合計(税込): ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '¥${formatYen(totalWithTax)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32, thickness: 2),
                // ユーザー情報（配送先）
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '配送先情報',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      if (userModel != null)
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('お名前: ${userModel.name ?? "未設定"}'),
                                Text('住所: ${userModel.address ?? "未設定"}'),
                                Text('電話番号: ${userModel.tel ?? "未設定"}'),
                                Text('Email: ${userModel.email ?? "未設定"}'),
                              ],
                            ),
                          ),
                        )
                      else
                        const Text(
                          'ユーザー情報が見つかりません。ログインしてください。',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32, thickness: 2),
                // 購入方法（支払い方法の選択）
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '購入方法（お支払い方法の選択）',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      paymentsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, st) => Text(
                          '支払い方法の取得に失敗: $e',
                          style: const TextStyle(color: Colors.red),
                        ),
                        data: (payments) {
                          if (payments == null || payments.isEmpty) {
                            return const Text('利用可能な支払い方法がありません');
                          }
                          return Column(
                            children: List<Widget>.generate(payments.length, (
                              i,
                            ) {
                              final pm = payments[i];
                              final paymentId = pm['id'] is int
                                  ? pm['id']
                                  : int.tryParse(pm['id'].toString());
                              final isSelected = selectedPaymentId == paymentId;
                              return ListTile(
                                leading: Radio<int>(
                                  value: paymentId,
                                  groupValue: selectedPaymentId,
                                  onChanged: (v) {
                                    setState(() {
                                      selectedPaymentId = v;
                                    });
                                  },
                                ),
                                title: Text(pm['name']?.toString() ?? '名称不明'),
                                tileColor: isSelected
                                    ? Colors.orange.shade50
                                    : null,
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 購入ボタン
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        (cartItems.isEmpty ||
                            userModel == null ||
                            selectedPaymentId == null)
                        ? null
                        : () async {
                            // 購入処理
                            try {
                              // ローディングインジケータを表示（任意でUI改善可能）
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator()),
                              );
                              final purchaseResult = await ref.read(
                                purchaseProvider(
                                  userModel.id,
                                  selectedPaymentId!,
                                  cartItems.map((item) => item.id as int).toList(),
                                  cartItems.map((item) => item.quantity as int).toList(),
                                ).future,
                              );
                              Navigator.of(context, rootNavigator: true).pop(); // ローディング消す

                              if (purchaseResult != null &&
                                  (purchaseResult['success'] == true)) {

                                ref.read(cartItemsProvider.notifier).state = [];
                                // ホームに戻る
                                if (mounted) {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('購入が完了しました。ありがとうございました！'),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      purchaseResult?['message']?.toString() ?? '購入に失敗しました',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              Navigator.of(context, rootNavigator: true).pop(); // ローディング消す
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('エラー: $e')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('購入する', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _priceLine(String label, int price) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text('¥${formatYen(price)}', style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
