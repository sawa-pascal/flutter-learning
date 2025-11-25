import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_application_ec_site/models/userModel/userModel.dart';
import 'myApiProvider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'utility.dart';

// 日付を日本語表記でフォーマットする関数
String formatJapaneseDate(DateTime? date) {
  if (date == null) return '';
  return '${date.year}年${date.month}月${date.day}日';
}

// APIなど履歴データの日付(例: "2024-06-07"や"2024/06/07") → 日本表記
String formatJapaneseDateString(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  // "2024-06-07" or "2024/06/07"
  final unifiedDateStr = dateStr.replaceAll('/', '-');
  final dt = DateTime.tryParse(unifiedDateStr);
  if (dt != null) return formatJapaneseDate(dt);

  // fallback (parse failed) - just replace -/ to "年/月/日"
  try {
    final parts = unifiedDateStr.split('-');
    if (parts.length == 3) {
      return '${parts[0]}年${int.parse(parts[1])}月${int.parse(parts[2])}日';
    }
  } catch (_) {}
  return dateStr; // fallback 原文
}

class PurchaseHistory extends ConsumerStatefulWidget {
  const PurchaseHistory({super.key});

  @override
  ConsumerState<PurchaseHistory> createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends ConsumerState<PurchaseHistory> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _orderIdController = TextEditingController();

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  // 履歴リストのフィルタ関数
  List<dynamic> filterHistories(List<dynamic> histories) {
    return histories.where((h) {
      bool orderFilter = true;
      bool dateFilter = true;
      final orderVal = (_orderIdController.text ?? '').trim();
      // 注文番号フィルター
      if (orderVal.isNotEmpty) {
        final orderIdStr = h['sale_id']?.toString() ?? '';
        orderFilter = orderIdStr.contains(orderVal);
      }
      // 日付フィルター
      if (_startDate != null || _endDate != null) {
        final dateStr = h['date']?.toString() ?? '';
        try {
          final purchaseDate = DateTime.tryParse(
            dateStr.replaceAll(RegExp(r'/'), '-'),
          );
          if (purchaseDate == null) {
            dateFilter = false;
          } else {
            if (_startDate != null &&
                purchaseDate.isBefore(_zeroTime(_startDate!))) {
              dateFilter = false;
            }
            if (_endDate != null &&
                purchaseDate.isAfter(_limitTime(_endDate!))) {
              dateFilter = false;
            }
          }
        } catch (_) {
          dateFilter = false;
        }
      }
      return orderFilter && dateFilter;
    }).toList();
  }

  DateTime _zeroTime(DateTime d) => DateTime(d.year, d.month, d.day, 0, 0, 0);
  DateTime _limitTime(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userModelProvider);
    final purchaseHistoriesAsync = ref.watch(
      purchaseHistoryProvider(userModel?.id ?? 1),
    );

    // Scaffoldを日本語ロケールを提供するLocalizationsでラップ
    return Localizations(
      locale: const Locale('ja', 'JP'),
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('購入履歴')),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 68), // avoid footer overlap
            child: purchaseHistoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('購入履歴の取得に失敗しました: $error')),
              data: (histories) {
                if (histories == null || histories.isEmpty) {
                  return const Center(child: Text('購入履歴がありません'));
                }

                // 履歴の絞り込み
                final filtered = filterHistories(histories);

                // 各履歴毎・全体 合計計算
                double totalSubtotal = 0;
                double totalTaxed = 0;
                for (var history in filtered) {
                  double subtotal = 0;
                  if (history['data'] is List) {
                    for (var data in history['data']) {
                      final price = (data['price'] ?? 0) as num;
                      final quantity = (data['quantity'] ?? 0) as num;
                      subtotal += price * quantity;
                    }
                    totalSubtotal += subtotal;
                    totalTaxed += (subtotal * 1.1).roundToDouble();
                  }
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                      child: Row(
                        children: [
                          // 日付 From
                          Flexible(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  locale: const Locale('ja', 'JP'),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _startDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: '開始日',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                child: Text(
                                  _startDate != null
                                      ? formatJapaneseDate(_startDate)
                                      : '',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // 日付 To
                          Flexible(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  locale: const Locale('ja', 'JP'),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _endDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: '終了日',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                child: Text(
                                  _endDate != null
                                      ? formatJapaneseDate(_endDate)
                                      : '',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // 注文番号
                          Flexible(
                            child: SizedBox(
                              height: 48,
                              child: TextField(
                                controller: _orderIdController,
                                decoration: const InputDecoration(
                                  labelText: '注文番号',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'フィルタクリア',
                            onPressed: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                                _orderIdController.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    if (filtered.isEmpty)
                      const Expanded(
                        child: Center(child: Text('条件に合致する購入履歴がありません')),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final history = filtered[idx];
                            double subtotal = 0;
                            double taxedTotal = 0;
                            if (history['data'] is List) {
                              for (var data in history['data']) {
                                final price = (data['price'] ?? 0) as num;
                                final quantity = (data['quantity'] ?? 0) as num;
                                subtotal += price * quantity;
                              }
                              taxedTotal = (subtotal * 1.1).roundToDouble();
                            }
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // saleId
                                    Text(
                                      '注文番号: ${history['sale_id'] ?? ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    // 購入日
                                    Text(
                                      '購入日: ${formatJapaneseDateString(history['date']?.toString())}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // 商品一覧
                                    if (history['data'] is List &&
                                        history['data'].isNotEmpty)
                                      ...List<Widget>.from(
                                        (history['data'] as List<dynamic>).map(
                                          (data) => ListTile(
                                            leading:
                                                data['item_image_url'] !=
                                                        null &&
                                                    data['item_image_url']
                                                        .toString()
                                                        .isNotEmpty
                                                ? Image.network(
                                                    imageBaseUrl +
                                                        data['item_image_url'],
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (
                                                          content,
                                                          object,
                                                          _,
                                                        ) => const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 40,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.image,
                                                    size: 40,
                                                  ),
                                            title: Text(
                                              data['item_name'] ?? '',
                                            ),
                                            subtitle: Text(
                                              '数量: ${data['quantity'] ?? ''}',
                                            ),
                                            trailing: Text(
                                              '￥${formatYen((data['price'] ?? 0) * (data['quantity'] ?? 0))}',
                                            ),
                                          ),
                                        ),
                                      ),
                                    const Divider(),
                                    // 合計計算
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '合計: ￥${formatYen(subtotal.round())}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '税込み合計: ￥${formatYen(taxedTotal.round())}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // 合計金額フッター
          bottomSheet: purchaseHistoriesAsync.when(
            data: (histories) {
              final filtered = (histories == null || histories.isEmpty)
                  ? []
                  : filterHistories(histories);

              double totalSubtotal = 0;
              double totalTaxed = 0;
              for (var history in filtered) {
                double subtotal = 0;
                if (history['data'] is List) {
                  for (var data in history['data']) {
                    final price = (data['price'] ?? 0) as num;
                    final quantity = (data['quantity'] ?? 0) as num;
                    subtotal += price * quantity;
                  }
                  totalSubtotal += subtotal;
                  totalTaxed += (subtotal * 1.1).roundToDouble();
                }
              }

              if (filtered.isEmpty) return const SizedBox();
              return Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  border: const Border(
                    top: BorderSide(color: Colors.grey, width: 0.6),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.summarize, color: Colors.orange, size: 32),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '履歴の合計: ￥${formatYen(totalSubtotal.round())}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '税込み合計: ￥${formatYen(totalTaxed.round())}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (err, stack) => const SizedBox(),
            // No orElse, as all states are handled above
          ),
        ),
      ),
    );
  }
}
