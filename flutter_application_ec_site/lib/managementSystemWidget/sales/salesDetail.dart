import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../myApiProvider.dart';

class SalesDetailPage extends ConsumerWidget {
  final int saleId;

  const SalesDetailPage({Key? key, required this.saleId}) : super(key: key);

  // 注文日は時間まで表示
  String formatJapaneseDateTime(dynamic date) {
    if (date == null) return '';
    DateTime? dt;
    if (date is DateTime) {
      dt = date;
    } else if (date is String) {
      final s = date.replaceAll('/', '-');
      dt = DateTime.tryParse(s);
      if (dt == null) {
        // 手動でパースを試す: 例 "2024-06-05 13:23:11"
        try {
          dt = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(s);
        } catch (_) {
          try {
            dt = DateFormat('yyyy-MM-ddTHH:mm:ss').parseStrict(s);
          } catch (_) {}
        }
      }
    }
    if (dt == null) return date?.toString() ?? '';
    // 「2024年6月5日 13:23:11」のように表示
    return '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  String formatYen(dynamic value) {
    final NumberFormat yenFormat = NumberFormat('#,##0');
    int? val;
    if (value is int) {
      val = value;
    } else if (value is num) {
      val = value.toInt();
    } else {
      val = int.tryParse(value?.toString() ?? '');
    }
    return val != null ? yenFormat.format(val) : (value?.toString() ?? '');
  }

  Widget _buildOrderDetails(BuildContext context, List<dynamic> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text('注文アイテムがありません'),
      );
    }

    // id, date, user_id, user_name, item_id, item_image_url, item_name, price, quantity

    // 先頭要素から共通情報を取得
    final firstItem = items.first as Map<String, dynamic>;

    final date = firstItem['date'];
    final userName = (firstItem['user_name'] ?? '').toString();
    // 合計金額を計算する
    int totalInt = 0;
    for (final item in items) {
      final price = item['price'] is int
          ? item['price']
          : item['price'] is num
              ? (item['price'] as num).toInt()
              : int.tryParse(item['price']?.toString() ?? '0') ?? 0;
      final qty = item['quantity'] is int
          ? item['quantity']
          : item['quantity'] is num
              ? (item['quantity'] as num).toInt()
              : int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      totalInt +=
          (price is num ? price.toInt() : 0) * (qty is num ? qty.toInt() : 0);
    }
    final total = (totalInt * 1.1).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Column(
              children: [
                _buildDetailRow('売上ID', saleId.toString()),
                _buildDetailRow('注文日', formatJapaneseDateTime(date)),
                _buildDetailRow(
                  'ユーザー名',
                  userName.isNotEmpty ? userName : 'ゲスト/未登録',
                ),
                _buildDetailRow('合計金額', '¥${formatYen(total)} (税込)'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 戻るボタンを追加
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('戻る'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[50],
                foregroundColor: Colors.blueGrey[800],
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            '注文商品一覧',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('画像')),
                DataColumn(label: Text('商品名')),
                DataColumn(label: Text('数量')),
                DataColumn(label: Text('単価')),
              ],
              rows: items.map((item) {
                final imageUrl =
                    imageBaseUrl + (item['item_image_url'] ?? '').toString();
                final proName = (item['item_name'] ?? '').toString();
                final qty = item['quantity'] ?? '';
                final price = formatYen(item['price']);
                return DataRow(
                  cells: [
                    DataCell(
                      imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported, size: 32),
                            )
                          : const Icon(Icons.image_not_supported, size: 32),
                    ),
                    DataCell(Text(proName)),
                    DataCell(Text(qty.toString())),
                    DataCell(Text('¥$price')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleItemsAsync = ref.watch(saleItemsProvider(saleId: saleId));
    return Scaffold(
      appBar: AppBar(title: const Text('売上詳細')),
      body: saleItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text('注文商品取得エラー: $e')),
        ),
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: _buildOrderDetails(context, data),
          );
        },
      ),
    );
  }
}
