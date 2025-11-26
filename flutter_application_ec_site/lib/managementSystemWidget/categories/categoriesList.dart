import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';
import '../paging.dart'; // ← Paginationウィジェットをインポート

class CategoriesListPage extends ConsumerStatefulWidget {
  const CategoriesListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesListPage> createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends ConsumerState<CategoriesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  int _cachedPageCount = 0; // ページ数をキャッシュ

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterCategories(List<dynamic> categories) {
    if (_searchText.isEmpty) return categories;
    final query = _searchText.toLowerCase();
    return categories.where((c) {
      final name = (c['name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  List<dynamic> _getPagedCategories(List<dynamic> categories) {
    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    if (start >= categories.length) return [];
    return categories.sublist(
      start,
      end > categories.length ? categories.length : end,
    );
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
    final categoriesAsync = ref.watch(categoriesProvider);

    List<dynamic> filtered = [];
    int pageCount = 0;
    List<dynamic> paged = [];

    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリー一覧')),
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
                  labelText: '名前で検索',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  if (categories == null || categories.isEmpty) {
                    filtered = [];
                    pageCount = 0;
                    paged = [];
                    return const Center(child: Text('カテゴリーがありません'));
                  }
                  filtered = _filterCategories(categories);
                  pageCount = _getPageCount(filtered.length);
                  _cachedPageCount = pageCount;
                  paged = _getPagedCategories(
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
                    return const Center(child: Text('該当するカテゴリーがありません'));
                  }
                  return Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('カテゴリ名')),
                          DataColumn(label: Text('表示順')),
                        ],
                        rows: paged.map<DataRow>((category) {
                          return DataRow(
                            cells: [
                              DataCell(Text('${category['id'] ?? '-'}')),
                              DataCell(Text('${category['name'] ?? '-'}')),
                              DataCell(
                                Text('${category['display_order'] ?? '-'}'),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('エラーが発生しました: $error')),
              ),
            ),
            // ページネーションを一番下に固定
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 2),
              child: Builder(
                builder: (context) {
                  // 状態によってページ数を参照
                  final actualPageCount = pageCount != 0 ? pageCount : _cachedPageCount;
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
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
