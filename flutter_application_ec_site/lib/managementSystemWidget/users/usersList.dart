import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/users/usersCreator.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/users/usersDetail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';
import '../managementSystemAppBar.dart';
import '../paging.dart';

class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  int _currentPage = 0;
  static const int _rowsPerPage = 7;
  int _cachedPageCount = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // このページを訪れるたびに強制リフレッシュ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(usersListProvider);
    });
    super.didChangeDependencies();
  }

  List<dynamic> _filterUsers(List<dynamic> users) {
    if (_searchText.isEmpty) return users;
    final query = _searchText.toLowerCase();
    return users.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  List<dynamic> _getPagedUsers(List<dynamic> users) {
    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    if (start >= users.length) return [];
    return users.sublist(start, end > users.length ? users.length : end);
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
    final usersAsync = ref.watch(usersListProvider(id: null));

    List<dynamic> filtered = [];
    int pageCount = 0;
    List<dynamic> paged = [];

    return Scaffold(
      drawer: const ManagementSystemDrawer(),
      appBar: managementSystemAppBar(context, title: 'ユーザー一覧'),
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
                    _currentPage = 0; // 検索時ページリセット
                  });
                },
                decoration: const InputDecoration(
                  labelText: '名前またはメールで検索',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: usersAsync.when(
                data: (data) {
                  List<dynamic> usersRaw = [];
                  if (data == null) {
                    filtered = [];
                    pageCount = 0;
                    paged = [];
                    return const Center(child: Text('ユーザーが見つかりません'));
                  }
                  var usersValue = data['users'];
                  if (usersValue == null) {
                    filtered = [];
                    pageCount = 0;
                    paged = [];
                    return const Center(child: Text('ユーザーが見つかりません'));
                  } else if (usersValue is List) {
                    usersRaw = usersValue;
                    if (usersRaw.isEmpty) {
                      filtered = [];
                      pageCount = 0;
                      paged = [];
                      return const Center(child: Text('ユーザーが見つかりません'));
                    }
                  } else if (usersValue is Map) {
                    usersRaw = [usersValue];
                  } else {
                    filtered = [];
                    pageCount = 0;
                    paged = [];
                    return const Center(child: Text('ユーザーが見つかりません'));
                  }

                  filtered = _filterUsers(usersRaw);
                  pageCount = _getPageCount(filtered.length);
                  _cachedPageCount = pageCount;
                  paged = _getPagedUsers(
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
                    return const Center(child: Text('一致するユーザーが見つかりません'));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: paged.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final user = paged[index];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'ID: ${user['id']?.toString() ?? '-'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      user['name'] ?? '未設定',
                                      style: const TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(user['email'] ?? ''),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UsersDetail(
                                          userId: user['id'] is int
                                              ? user['id']
                                              : int.tryParse(user['id'].toString()) ?? 0,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 2),
                        child: Builder(
                          builder: (context) {
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
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('ユーザー取得エラー: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => UsersCreator()));
        },
        child: const Icon(Icons.add),
        tooltip: 'ユーザー追加',
      ),
    );
  }
}
