import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/models/cartItemModel/cartItemModel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'login.dart';
import 'myApiProvider.dart';
import 'purchase.dart';
import 'models/userModel/userModel.dart';
import 'utility.dart';

// ============================================================================
// 定数定義
// ============================================================================

/// 消費税率
const double _taxRate = 1.1;

/// カートアイテムのパディング
const EdgeInsets _cartItemPadding = EdgeInsets.symmetric(
  vertical: 4.0,
  horizontal: 0,
);

/// 商品画像のサイズ
const double _itemImageSize = 50.0;

/// 合計バーのパディング
const EdgeInsets _totalBarPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 12,
);

/// 合計バーのタイトルフォントサイズ
const double _totalBarTitleFontSize = 18.0;

/// 合計バーの価格フォントサイズ
const double _totalBarPriceFontSize = 22.0;

/// 合計バーの価格とタイトルの間隔
const double _totalBarSpacing = 18.0;

// ============================================================================
// カート画面ウィジェット
// ============================================================================

/// カート画面のウィジェット
/// 
/// カート内の商品一覧を表示し、数量変更や削除、購入処理を提供します。
class Cart extends ConsumerStatefulWidget {
  const Cart({super.key});

  @override
  ConsumerState<Cart> createState() => _CartState();
}

class _CartState extends ConsumerState<Cart> {
  // ==========================================================================
  // カート操作メソッド
  // ==========================================================================

  /// カートアイテムの数量を変更
  /// 
  /// [item]: 数量を変更するカートアイテム
  /// [delta]: 変更量（正の値で増加、負の値で減少）
  /// [cartItemsNotifier]: カートアイテムの状態コントローラー
  void _changeQuantity({
    required CartItemModel item,
    required int delta,
    required StateController<List<CartItemModel>> cartItemsNotifier,
  }) {
    cartItemsNotifier.state = [
      for (final cartItem in cartItemsNotifier.state)
        if (cartItem.id == item.id)
          cartItem.copyWith(
            quantity: (cartItem.quantity + delta).clamp(1, cartItem.stock),
          )
        else
          cartItem,
    ];
  }

  /// カートアイテムを削除
  /// 
  /// [item]: 削除するカートアイテム
  /// [cartItemsNotifier]: カートアイテムの状態コントローラー
  void _deleteCartItem(
    CartItemModel item,
    StateController<List<CartItemModel>> cartItemsNotifier,
  ) {
    cartItemsNotifier.state = [
      for (final cartItem in cartItemsNotifier.state)
        if (cartItem.id != item.id) cartItem,
    ];
  }

  // ==========================================================================
  // UI構築メソッド
  // ==========================================================================

  /// 数量コントロールを構築
  /// 
  /// 数量の増減ボタンと削除ボタンを表示します。
  Widget _buildQuantityControls(
    BuildContext context,
    CartItemModel item,
    StateController<List<CartItemModel>> cartItemsNotifier,
  ) {
    return Row(
      children: [
        const Text('選択数: '),
        _buildDecreaseButton(item, cartItemsNotifier),
        Text(
          '${item.quantity}',
          style: const TextStyle(fontSize: 16),
        ),
        _buildIncreaseButton(item, cartItemsNotifier),
        _buildDeleteButton(item, cartItemsNotifier),
      ],
    );
  }

  /// 数量減少ボタンを構築
  Widget _buildDecreaseButton(
    CartItemModel item,
    StateController<List<CartItemModel>> cartItemsNotifier,
  ) {
    return GestureDetector(
      onLongPressStart: item.quantity > 1
          ? (_) {
              startLongPressRepeater(() {
                if (item.quantity > 1) {
                  _changeQuantity(
                    item: item,
                    delta: -1,
                    cartItemsNotifier: cartItemsNotifier,
                  );
                }
              });
            }
          : null,
      onLongPressEnd: (_) => stopLongPressRepeater(),
      child: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: item.quantity > 1
            ? () {
                _changeQuantity(
                  item: item,
                  delta: -1,
                  cartItemsNotifier: cartItemsNotifier,
                );
              }
            : null,
      ),
    );
  }

  /// 数量増加ボタンを構築
  Widget _buildIncreaseButton(
    CartItemModel item,
    StateController<List<CartItemModel>> cartItemsNotifier,
  ) {
    return GestureDetector(
      onLongPressStart: item.quantity < item.stock
          ? (_) {
              startLongPressRepeater(() {
                if (item.quantity < item.stock) {
                  _changeQuantity(
                    item: item,
                    delta: 1,
                    cartItemsNotifier: cartItemsNotifier,
                  );
                }
              });
            }
          : null,
      onLongPressEnd: (_) => stopLongPressRepeater(),
      child: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: item.quantity < item.stock
            ? () {
                _changeQuantity(
                  item: item,
                  delta: 1,
                  cartItemsNotifier: cartItemsNotifier,
                );
              }
            : null,
      ),
    );
  }

  /// 削除ボタンを構築
  Widget _buildDeleteButton(
    CartItemModel item,
    StateController<List<CartItemModel>> cartItemsNotifier,
  ) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.redAccent),
      tooltip: '削除',
      onPressed: () {
        _deleteCartItem(item, cartItemsNotifier);
      },
    );
  }

  /// カートアイテムを構築
  /// 
  /// 商品情報、数量コントロール、小計・税込み価格を表示します。
  Widget _buildCartItem(
    BuildContext context,
    CartItemModel item,
    StateController<List<CartItemModel>> cartItemsNotifier,
  ) {
    final int subTotal = item.price * item.quantity;
    final int taxedSubTotal = (subTotal * _taxRate).round();

    return Padding(
      padding: _cartItemPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildItemImage(item),
          Expanded(
            child: _buildItemInfo(context, item, cartItemsNotifier),
          ),
          _buildItemPrice(subTotal, taxedSubTotal),
        ],
      ),
    );
  }

  /// 商品画像を構築
  Widget _buildItemImage(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: item.image_url.isNotEmpty
          ? Image.network(
              imageBaseUrl + item.image_url,
              width: _itemImageSize,
              height: _itemImageSize,
              fit: BoxFit.contain,
            )
          : const Icon(Icons.image_outlined, size: _itemImageSize),
    );
  }

  /// 商品情報を構築
  Widget _buildItemInfo(
    BuildContext context,
    CartItemModel item,
    StateController<List<CartItemModel>> cartItemsNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        Text('価格: ¥${formatYen(item.price)}'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildQuantityControls(context, item, cartItemsNotifier),
        ),
      ],
    );
  }

  /// 商品価格情報を構築
  Widget _buildItemPrice(int subTotal, int taxedSubTotal) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 10, top: 3),
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
    );
  }

  /// 合計バーを構築
  /// 
  /// 税込み合計金額と購入ボタンを表示します。
  Widget _buildTotalBar(
    BuildContext context,
    int totalPrice,
    UserModel? user,
  ) {
    final int taxedTotal = (totalPrice * _taxRate).round();

    return Container(
      padding: _totalBarPadding,
      color: Colors.grey.shade100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '税込み合計',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _totalBarTitleFontSize,
            ),
          ),
          const SizedBox(width: _totalBarSpacing),
          Text(
            '¥${formatYen(taxedTotal)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _totalBarPriceFontSize,
              color: Colors.deepOrange,
            ),
          ),
          const Spacer(),
          _buildPurchaseButton(context, user),
        ],
      ),
    );
  }

  /// 購入ボタンを構築
  Widget _buildPurchaseButton(BuildContext context, UserModel? user) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ElevatedButton.icon(
        onPressed: () => _handlePurchaseButtonPressed(context, user),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.shopping_bag),
        label: const Text('購入する'),
      ),
    );
  }

  /// 購入ボタン押下時の処理
  void _handlePurchaseButtonPressed(BuildContext context, UserModel? user) {
    if (user == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PurchasePage()),
      );
    }
  }

  /// カートの合計金額を計算
  /// 
  /// [cartItems]: カートアイテムのリスト
  /// 
  /// 戻り値: 合計金額（税抜き）
  int _calculateTotalPrice(List<CartItemModel> cartItems) {
    return cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // ==========================================================================
  // ビルドメソッド
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartItemsProvider);
    final cartItemsNotifier = ref.read(cartItemsProvider.notifier);
    final user = ref.watch(userModelProvider);
    final totalPrice = _calculateTotalPrice(cartItems);

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
                    itemBuilder: (context, index) => _buildCartItem(
                      context,
                      cartItems[index],
                      cartItemsNotifier,
                    ),
                  ),
                ),
                _buildTotalBar(context, totalPrice, user),
              ],
            ),
    );
  }
}
