import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/items/itemsCreator.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/items/itemsDetail.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/categories/categoriesDetail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';
import '../paging.dart'; // ← Paginationウィジェットをインポート
import '../managementSystemAppBar.dart'; // 共通AppBarのインポート

class ItemsListPage extends ConsumerStatefulWidget {
  const ItemsListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ItemsListPage> createState() => _ItemsListPageState();
}

class _ItemsListPageState extends ConsumerState<ItemsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  int _cachedPageCount = 0; // ページ数をキャッシュ
  int? _selectedCategoryId; // 選択中のカテゴリーID

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // このページを訪れるたびに強制リフレッシュ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(itemsProvider);
    });
    super.didChangeDependencies();
  }

  List<dynamic> _filterItems(List<dynamic> items) {
    if (_searchText.isEmpty) return items;
    final query = _searchText.toLowerCase();
    return items.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  List<dynamic> _getPagedItems(List<dynamic> items) {
    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    if (start >= items.length) return [];
    return items.sublist(start, end > items.length ? items.length : end);
  }

  int _getPageCount(int itemCount) {
    return (itemCount / _rowsPerPage).ceil();
  }

  void _handlePageChanged(int page, int pageCount) {
    setState(() {
      if (page < 0) {
        _currentPage = 0;
      } else if (page >= pageCount) {
        _currentPage = pageCount - 1;
      } else {
        _currentPage = page;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);
    final categoriesAsync = ref.watch(categoriesProvider());

    List<dynamic> filtered = [];
    int pageCount = 0;
    List<dynamic> paged = [];

    return Scaffold(
      drawer: ManagementSystemDrawer(),
      appBar: managementSystemAppBar(context, title: '商品一覧'), // 共通AppBarを使用
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchText = val;
                    _currentPage = 0; // Reset page on search
                  });
                },
                decoration: const InputDecoration(
                  labelText: '商品名で検索',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('カテゴリー情報の取得エラー: $error')),
                data: (categories) {
                  // Map<categoryId, categoryObject> を作っておく
                  final Map<int, dynamic> categoryIdMap = {};
                  if (categories is List) {
                    for (var cat in categories) {
                      final id = cat['id'];
                      if (id is int) categoryIdMap[id] = cat;
                    }
                  }

                  return itemsAsync.when(
                    data: (items) {
                      if (items == null || items.isEmpty) {
                        filtered = [];
                        pageCount = 0;
                        paged = [];
                        return const Center(child: Text('商品がありません'));
                      }
                      filtered = _filterItems(items);
                      pageCount = _getPageCount(filtered.length);
                      _cachedPageCount = pageCount;
                      paged = _getPagedItems(
                        filtered..sort((a, b) {
                          final aId = a['id'];
                          final bId = b['id'];
                          if (aId is int && bId is int) {
                            return aId.compareTo(bId);
                          }
                          return 0;
                        }),
                      );
                      if (filtered.isEmpty) {
                        return const Center(child: Text('該当する商品がありません'));
                      }
                      return Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('商品名')),
                              DataColumn(label: Text('カテゴリー')),
                              DataColumn(label: Text('価格')),
                              DataColumn(label: Text('在庫')),
                            ],
                            rows: paged.map<DataRow>((item) {
                              // カテゴリー名へ：item['category_id'] をカテゴリー名に変換、タップでカテゴリー詳細画面に遷移、選択状態を背景色で反転
                              final categoryId = item['category_id'];
                              String categoryName = '-';
                              if (categoryId != null) {
                                final cat = categoryIdMap[categoryId];
                                if (cat != null &&
                                    cat['name'] != null &&
                                    cat['name'].toString().trim().isNotEmpty) {
                                  categoryName = cat['name'].toString();
                                }
                              }

                              final bool isCategorySelected =
                                  _selectedCategoryId != null &&
                                  categoryId != null &&
                                  _selectedCategoryId == categoryId;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    TextButton(
                                      child: Text('${item['id'] ?? '-'}'),
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ItemsDetailPage(item: item),
                                            ),
                                          ),
                                    ),
                                  ),
                                  DataCell(Text('${item['name'] ?? '-'}')),
                                  DataCell(
                                    TextButton(
                                      child: Text('${categoryName ?? '-'}'),
                                      onPressed: () {
                                        setState(() {
                                          _selectedCategoryId = categoryId;
                                        });
                                        if (categoryId != null) {
                                          Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CategoriesDetailPage(
                                                        categoryId: categoryId,
                                                      ),
                                                ),
                                              )
                                              .then((_) {
                                                // 戻った時に選択解除
                                                setState(() {
                                                  _selectedCategoryId = null;
                                                });
                                              });
                                        }
                                      },
                                    ),
                                  ),

                                  DataCell(
                                    Text(
                                      item['price'] != null
                                          ? '¥${item['price']}'
                                          : '-',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      item['quantity'] != null
                                          ? '${item['quantity']}'
                                          : '-',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('エラーが発生しました: $error')),
                  );
                },
              ),
            ),
            // ページネーションを一番下に固定
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 2),
              child: Builder(
                builder: (context) {
                  // 状態によってページ数を参照
                  final actualPageCount = pageCount != 0
                      ? pageCount
                      : _cachedPageCount;
                  return Pagination(
                    currentPage: _currentPage,
                    pageCount: actualPageCount,
                    onPageChanged: (page) =>
                        _handlePageChanged(page, actualPageCount),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // カテゴリー作成ページから戻った時も更新
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ItemsCreatorPage()),
          );
          if (result == true) {
            // 新規作成時もリフレッシュ
            ref.invalidate(categoriesProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
