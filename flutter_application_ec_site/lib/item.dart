import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'myApiProvider.dart';
import 'models/cartItemModel/cartItemModel.dart';
import 'utility.dart';

// ============================================================================
// 定数定義
// ============================================================================

const double _categoryHeaderPaddingHorizontal = 16.0;
const double _categoryHeaderPaddingVertical = 12.0;
const double _categoryBottomSpacing = 16.0;
const double _categoryTitleFontSize = 18.0;
const double _categoryDividerThickness = 2.0;

const Duration _scrollAnimationDuration = Duration(milliseconds: 500);
const Duration _scrollRetryDelay = Duration(milliseconds: 300);
const int _scrollMaxRetries = 8;

const double _itemCardMarginHorizontal = 12.0;
const double _itemCardMarginVertical = 8.0;
const double _itemImageSize = 56.0;

// ============================================================================
// 商品リストウィジェット
// ============================================================================

/// 商品リストを表示するウィジェット
class ItemList extends ConsumerStatefulWidget {
  final List<dynamic> items;
  final ScrollController? scrollController;
  final int? selectedCategoryId;
  final VoidCallback? onCategoryScrolled;

  const ItemList({
    Key? key,
    required this.items,
    this.scrollController,
    this.selectedCategoryId,
    this.onCategoryScrolled,
  }) : super(key: key);

  @override
  ConsumerState<ItemList> createState() => _ItemListState();
}

class _ItemListState extends ConsumerState<ItemList> {
  final Map<int, GlobalKey> _categoryKeys = {};
  final Map<int, double> _categoryPositions = {};
  List<Map<String, dynamic>> _sortedCategories = [];
  Map<String, List<dynamic>> _itemsByCategory = {};

  @override
  void didUpdateWidget(ItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != null &&
        widget.selectedCategoryId != oldWidget.selectedCategoryId &&
        widget.scrollController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCategory(widget.selectedCategoryId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('カテゴリー取得失敗: $error')),
      data: (categories) {
        _itemsByCategory = _groupItemsByCategory(widget.items);
        _sortedCategories = _sortCategories(categories);
        _ensureCategoryKeys();

        return ListView.separated(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _sortedCategories.length,
          separatorBuilder: (context, index) => const Divider(
            height: 0,
            thickness: _categoryDividerThickness,
            color: Colors.grey,
          ),
          itemBuilder: _buildCategorySection,
        );
      },
    );
  }

  Map<String, List<dynamic>> _groupItemsByCategory(List<dynamic> items) {
    final map = <String, List<dynamic>>{};
    for (final item in items) {
      final cid = item['category_id']?.toString() ?? '0';
      map.putIfAbsent(cid, () => []).add(item);
    }
    return map;
  }

  List<Map<String, dynamic>> _sortCategories(List<dynamic> categories) {
    final sorted = List<Map<String, dynamic>>.from(categories);
    sorted.sort((a, b) {
      final ao = int.tryParse(a['order'].toString()) ?? 9999;
      final bo = int.tryParse(b['order'].toString()) ?? 9999;
      return ao.compareTo(bo);
    });
    return sorted;
  }

  void _ensureCategoryKeys() {
    for (final category in _sortedCategories) {
      final categoryId = int.tryParse(category['id'].toString());
      if (categoryId != null && !_categoryKeys.containsKey(categoryId)) {
        _categoryKeys[categoryId] = GlobalKey();
      }
    }
  }

  Widget _buildCategorySection(BuildContext context, int index) {
    final category = _sortedCategories[index];
    final categoryIdStr = category['id'].toString();
    final categoryId = int.tryParse(categoryIdStr);
    final categoryName = category['name']?.toString() ?? '未分類';
    final categoryItems = _itemsByCategory[categoryIdStr] ?? [];

    if (categoryItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return ItemCategorySection(
      key: categoryId != null ? _categoryKeys[categoryId] : null,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryItems: categoryItems,
      scrollController: widget.scrollController,
      onPositionMeasured: categoryId != null && widget.scrollController != null
          ? (position) => _categoryPositions[categoryId] = position
          : null,
    );
  }

  /// カテゴリーIDから表示インデックスを算出（空のカテゴリーはスキップ）
  int? _getCategoryIndex(int categoryId) {
    final categoryIdStr = categoryId.toString();
    int displayIndex = 0;

    for (final category in _sortedCategories) {
      final catIdStr = category['id'].toString();
      final categoryItems = _itemsByCategory[catIdStr] ?? [];
      if (categoryItems.isEmpty) {
        continue;
      }
      if (catIdStr == categoryIdStr) {
        return displayIndex;
      }
      displayIndex++;
    }
    return null;
  }

  /// 指定したカテゴリー位置へスクロール
  void _scrollToCategory(int categoryId) {
    final key = _categoryKeys[categoryId];
    if (key == null) return;

    final context = key.currentContext;
    if (context != null) {
      _ensureVisible(context).then((_) => _notifyScrollCompleted());
      return;
    }

    _scrollToCategoryWithRetry(categoryId, key, 0);
  }

  void _scrollToCategoryWithRetry(
    int categoryId,
    GlobalKey key,
    int retryCount,
  ) {
    final controller = widget.scrollController;
    if (controller == null) return;

    if (retryCount >= _scrollMaxRetries) {
      debugPrint('カテゴリー（$categoryId）へのスクロールが失敗しました。');
      _notifyScrollCompleted();
      return;
    }

    if (_categoryPositions.containsKey(categoryId)) {
      final knownPosition = _categoryPositions[categoryId]!;
      controller
          .animateTo(
            knownPosition.clamp(
              0.0,
              controller.position.maxScrollExtent,
            ),
            duration: _scrollAnimationDuration,
            curve: Curves.easeInOut,
          )
          .then((_) => _attemptContextEnsure(key, categoryId, retryCount));
      return;
    }

    final categoryIndex = _getCategoryIndex(categoryId);
    if (categoryIndex == null) {
      debugPrint('カテゴリー（$categoryId）のインデックスが取得できませんでした。');
      return;
    }

    final targetOffset = _calculateTargetOffset(
      categoryIndex,
      retryCount,
      controller,
    );

    controller
        .animateTo(
          targetOffset,
          duration: _scrollAnimationDuration,
          curve: Curves.easeOut,
        )
        .then((_) => _attemptContextEnsure(key, categoryId, retryCount));
  }

  void _attemptContextEnsure(
    GlobalKey key,
    int categoryId,
    int retryCount,
  ) {
    Future.delayed(_scrollRetryDelay, () {
      final context = key.currentContext;
      if (context != null) {
        _recordCategoryPosition(key, categoryId);
        _ensureVisible(context).then((_) => _notifyScrollCompleted());
      } else {
        _scrollToCategoryWithRetry(categoryId, key, retryCount + 1);
      }
    });
  }

  Future<void> _ensureVisible(BuildContext context) {
    return Scrollable.ensureVisible(
      context,
      duration: _scrollAnimationDuration,
      curve: Curves.easeInOut,
      alignment: 0.0,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  void _recordCategoryPosition(GlobalKey key, int categoryId) {
    final controller = widget.scrollController;
    if (controller == null) return;

    final context = key.currentContext;
    final renderBox = context?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final actualPosition = controller.offset + position.dy;
    _categoryPositions[categoryId] = actualPosition;
  }

  double _calculateTargetOffset(
    int categoryIndex,
    int retryCount,
    ScrollController controller,
  ) {
    const estimatedHeight = 1000.0;
    double targetOffset;

    if (retryCount < 4) {
      targetOffset = categoryIndex * estimatedHeight * 0.3 * (retryCount + 1);
    } else {
      targetOffset =
          categoryIndex * estimatedHeight * 0.5 + (retryCount - 3) * 500;
    }

    return targetOffset.clamp(
      0.0,
      controller.position.maxScrollExtent,
    );
  }

  void _notifyScrollCompleted() {
    widget.onCategoryScrolled?.call();
  }
}

/// カテゴリーセクションのラッパー（位置測定機能付き）
class ItemCategorySection extends StatefulWidget {
  final Key? key;
  final int? categoryId;
  final String categoryName;
  final List<dynamic> categoryItems;
  final Function(double)? onPositionMeasured;
  final ScrollController? scrollController;

  const ItemCategorySection({
    this.key,
    this.categoryId,
    required this.categoryName,
    required this.categoryItems,
    this.onPositionMeasured,
    this.scrollController,
  }) : super(key: key);

  @override
  State<ItemCategorySection> createState() => _ItemCategorySectionState();
}

class _ItemCategorySectionState extends State<ItemCategorySection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measurePosition());
  }

  @override
  void didUpdateWidget(ItemCategorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measurePosition());
  }

  void _measurePosition() {
    if (widget.categoryId == null ||
        widget.onPositionMeasured == null ||
        widget.scrollController == null) {
      return;
    }

    final globalKey = widget.key is GlobalKey ? widget.key as GlobalKey : null;
    final context = globalKey?.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final scrollPosition = widget.scrollController!.offset;
    final actualPosition = scrollPosition + position.dy;
    widget.onPositionMeasured!(actualPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _categoryBottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _categoryHeaderPaddingHorizontal,
              vertical: _categoryHeaderPaddingVertical,
            ),
            child: Text(
              widget.categoryName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _categoryTitleFontSize,
                color: Colors.blueGrey,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.categoryItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) =>
                ItemCard(item: widget.categoryItems[index]),
          ),
        ],
      ),
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
            margin: const EdgeInsets.symmetric(
              vertical: _itemCardMarginVertical,
              horizontal: _itemCardMarginHorizontal,
            ),
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
                            isSoldOut,
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
    bool isSoldOut,
  ) {
    showDialog(
      context: context,
      builder: (context) => ItemDetailDialog(
        ref: ref,
        item: item,
        name: name,
        imageUrl: imageUrl,
        price: price,
        description: description,
        stockLabel: stock,
        isSoldOut: isSoldOut,
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
            width: _itemImageSize,
            height: _itemImageSize,
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

// ============================================================================
// 商品詳細ダイアログ
// ============================================================================

class ItemDetailDialog extends StatefulWidget {
  final WidgetRef ref;
  final dynamic item;
  final String name;
  final String? imageUrl;
  final String? price;
  final String? description;
  final String? stockLabel;
  final bool isSoldOut;

  const ItemDetailDialog({
    super.key,
    required this.ref,
    required this.item,
    required this.name,
    this.imageUrl,
    this.price,
    this.description,
    this.stockLabel,
    this.isSoldOut = false,
  });

  @override
  State<ItemDetailDialog> createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends State<ItemDetailDialog> {
  late final ValueNotifier<int> _quantityNotifier;
  late final int _maxStock;

  bool get _isSoldOut => widget.isSoldOut || _maxStock == 0;

  @override
  void initState() {
    super.initState();
    _quantityNotifier = ValueNotifier<int>(1);
    _maxStock = widget.item['quantity'] is int
        ? widget.item['quantity']
        : int.tryParse(widget.item['quantity'].toString()) ?? 0;
  }

  @override
  void dispose() {
    _quantityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  if (widget.imageUrl != null) _buildHeroImage(),
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 8),
                  if (widget.description != null &&
                      widget.description!.trim().isNotEmpty)
                    _buildDescription(),
                  const SizedBox(height: 20),
                  _buildQuantitySelector(),
                  const SizedBox(height: 12),
                  _buildAddToCartButton(),
                  const SizedBox(height: 8),
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
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        widget.imageUrl!,
        fit: BoxFit.contain,
        height: 180,
        errorBuilder: (_, __, ___) => const Icon(Icons.image),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.price != null)
          Text(
            widget.price!,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.cyan,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (widget.stockLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _isSoldOut ? '売り切れ' : widget.stockLabel!,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isSoldOut ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.description!,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('選択数: '),
        _buildQuantityButton(
          icon: Icons.remove_circle_outline,
          enabled: !_isSoldOut && _quantityNotifier.value > 1,
          onPressed: () => _updateQuantity(-1),
        ),
        ValueListenableBuilder<int>(
          valueListenable: _quantityNotifier,
          builder: (context, value, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        _buildQuantityButton(
          icon: Icons.add_circle_outline,
          enabled: !_isSoldOut && _quantityNotifier.value < _maxStock,
          onPressed: () => _updateQuantity(1),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onLongPressStart: enabled
          ? (_) {
              startLongPressRepeater(() {
                onPressed();
              });
            }
          : null,
      onLongPressEnd: (_) => stopLongPressRepeater(),
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSoldOut ? Colors.grey : Colors.orange,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.shopping_cart_outlined),
        label: Text(_isSoldOut ? '売り切れ' : 'カートへ追加'),
        onPressed: _isSoldOut ? null : _handleAddToCart,
      ),
    );
  }

  void _updateQuantity(int delta) {
    _quantityNotifier.value =
        (_quantityNotifier.value + delta).clamp(1, _maxStock);
    setState(() {});
  }

  void _handleAddToCart() {
    final quantityToAdd = _quantityNotifier.value;
    if (_maxStock != 0 && quantityToAdd > _maxStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('在庫数を超えています')),
      );
      return;
    }

    final cartItem = CartItemModel(
      id: widget.item['id'] is int
          ? widget.item['id']
          : int.tryParse(widget.item['id'].toString()) ?? 0,
      name: widget.item['name'] ?? '',
      price: widget.item['price'] is int
          ? widget.item['price']
          : int.tryParse(widget.item['price'].toString()) ?? 0,
      stock: widget.item['quantity'] is int
          ? widget.item['quantity']
          : int.tryParse(widget.item['quantity'].toString()) ?? 0,
      quantity: quantityToAdd,
      image_url: widget.item['image_url']?.toString() ?? '',
    );

    final cartItems = widget.ref.read(cartItemsProvider);
    final existingIndex = cartItems.indexWhere((ci) => ci.id == cartItem.id);

    if (existingIndex != -1) {
      final updatedCartItems = [...cartItems];
      final existingItem = updatedCartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantityToAdd;
      if (_maxStock != 0 && newQuantity > _maxStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'カートにすでに ${existingItem.quantity} 個あり、合わせると在庫数 $_maxStock を超える数量です',
            ),
          ),
        );
        return;
      }
      updatedCartItems[existingIndex] =
          existingItem.copyWith(quantity: newQuantity);
      widget.ref.read(cartItemsProvider.notifier).state = updatedCartItems;
    } else {
      widget.ref.read(cartItemsProvider.notifier).state = [
        ...cartItems,
        cartItem,
      ];
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('カートに${quantityToAdd}個追加しました')),
    );
  }
}
