import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/sales/salesDetail.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/users/usersDetail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';
import '../paging.dart';
import '../managementSystemAppBar.dart';
import 'package:intl/intl.dart';

final salesListProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => salesList(ref),
);

String formatJapaneseDate(DateTime? date) =>
    date == null ? '' : '${date.year}年${date.month}月${date.day}日';

String formatJapaneseDateString(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  final unified = dateStr.replaceAll('/', '-');
  final dt = DateTime.tryParse(unified);
  if (dt != null) return formatJapaneseDate(dt);
  try {
    final parts = unified.split('-');
    if (parts.length == 3) {
      return '${parts[0]}年${int.parse(parts[1])}月${int.parse(parts[2])}日';
    }
  } catch (_) {}
  return dateStr;
}

final NumberFormat yenFormat = NumberFormat('#,##0');
final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
final DateFormat justDateFormat = DateFormat('yyyy-MM-dd');

class SalesListPage extends ConsumerStatefulWidget {
  const SalesListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends ConsumerState<SalesListPage> {
  String? _selectedUserName;
  List<String> _userNames = [];
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  int _cachedPageCount = 0;

  List<dynamic> _allSalesRaw = [];
  bool _initUserNamesFetched = false;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(salesListProvider);
    });
    super.didChangeDependencies();
  }

  List<dynamic> _filterSales(
    List<dynamic> sales, {
    String? userName,
    String? startString,
    String? endString,
  }) {
    DateTime? parseInput(String? s, {bool end = false}) {
      if (s == null || s.trim().isEmpty) return null;
      try {
        final value = s.trim();
        if (RegExp(r'^\d{8}$').hasMatch(value)) {
          DateTime dt = DateTime(
            int.parse(value.substring(0, 4)),
            int.parse(value.substring(4, 6)),
            int.parse(value.substring(6, 8)),
          );
          if (end) dt = DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);
          return dt;
        }
        DateTime? dt = DateTime.tryParse(value);
        if (dt != null && end) {
          dt = DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);
        }
        return dt;
      } catch (_) {
        return null;
      }
    }

    final DateTime? start = parseInput(startString);
    final DateTime? end = parseInput(endString, end: true);

    return sales.where((s) {
      if (userName != null &&
          userName.isNotEmpty &&
          userName != '-全て-' &&
          (s['user_name'] ?? '') != userName) {
        return false;
      }
      DateTime? saleDate;
      final d = s['date'];
      if (d is DateTime) {
        saleDate = d;
      } else if (d is String && d.trim().isNotEmpty) {
        saleDate = DateTime.tryParse(d);
      }
      if (saleDate == null) return false;
      if (start != null &&
          saleDate.isBefore(DateTime(start.year, start.month, start.day))) {
        return false;
      }
      if (end != null &&
          saleDate.isAfter(
            DateTime(end.year, end.month, end.day, 23, 59, 59, 999),
          )) {
        return false;
      }
      return true;
    }).toList();
  }

  List<dynamic> _getPagedSales(List<dynamic> sales) {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, sales.length);
    if (start >= sales.length) return [];
    return sales.sublist(start, end);
  }

  int _getPageCount(int itemCount) => (itemCount / _rowsPerPage).ceil();

  void _handlePageChanged(int page, int pageCount) {
    setState(() {
      _currentPage = page.clamp(0, pageCount - 1);
    });
  }

  int _withTax(int price) => ((price * 1.1).round());

  String _formatDateTime(dynamic dateValue) {
    if (dateValue == null) return '';
    if (dateValue is DateTime) {
      return dateTimeFormat.format(dateValue);
    }
    if (dateValue is String && dateValue.trim().isNotEmpty) {
      final DateTime? dt = DateTime.tryParse(dateValue);
      return dt != null ? dateTimeFormat.format(dt) : dateValue;
    }
    return dateValue.toString();
  }

  String _formatDateForInput(DateTime? date) =>
      date == null ? '' : justDateFormat.format(date);

  Future<void> _pickDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onPicked,
  ) async {
    final DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesListProvider);
    return Scaffold(
      drawer: const ManagementSystemDrawer(),
      appBar: managementSystemAppBar(context, title: '売上一覧'),
      body: SafeArea(child: _buildBody(salesAsync)),
    );
  }

  Widget _buildBody(AsyncValue<Map<String, dynamic>> salesAsync) {
    return salesAsync.when(
      data: (data) {
        if (data == null || data['sales'] == null) {
          return _buildNoData('売上データが見つかりません');
        }
        List<dynamic> salesRaw;
        var salesValue = data['sales'];

        if (salesValue is List) {
          salesRaw = salesValue;
          if (salesRaw.isEmpty) return _buildNoData('売上データが見つかりません');
        } else if (salesValue is Map) {
          salesRaw = [salesValue];
        } else {
          return _buildNoData('売上データが見つかりません');
        }

        _initUserNamesIfNeeded(salesRaw);

        final filtered = _filterSales(
          salesRaw,
          userName: _selectedUserName,
          startString: _startDate != null
              ? justDateFormat.format(_startDate!)
              : '',
          endString: _endDate != null ? justDateFormat.format(_endDate!) : '',
        );

        final pageCount = _getPageCount(filtered.length);
        _cachedPageCount = pageCount;
        final paged = _getPagedSales(filtered);

        if (filtered.isEmpty) {
          return Column(
            children: [
              _buildFilters(context),
              const Expanded(child: Center(child: Text('一致する売上が見つかりません'))),
            ],
          );
        }

        // 合計金額をフィルタ後のリストから計算し直す
        int filteredRawTotal = 0;
        for (final sale in filtered) {
          final t = sale['total'];
          if (t is int) {
            filteredRawTotal += t;
          } else if (t != null) {
            filteredRawTotal += int.tryParse('$t') ?? 0;
          }
        }
        final int filteredSalesTotal = _withTax(filteredRawTotal);

        return Column(
          children: [
            const SizedBox(height: 12),
            _buildUserDropdown(),
            const SizedBox(width: 12),
            _buildFilters(context),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                child: Text(
                  '全売上合計: ${yenFormat.format(filteredSalesTotal)} 円 (税込)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildSalesTable(paged)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Pagination(
                currentPage: _currentPage,
                pageCount: pageCount,
                onPageChanged: (page) => _handlePageChanged(page, pageCount),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('エラー: $e')),
    );
  }

  Widget _buildNoData(String msg) {
    return Center(child: Text(msg));
  }

  void _initUserNamesIfNeeded(List<dynamic> salesRaw) {
    if (!_initUserNamesFetched || _allSalesRaw.isEmpty) {
      _allSalesRaw = salesRaw;
      final userNamesSet = <String>{};
      for (final s in salesRaw) {
        final uname = (s['user_name'] ?? '').toString();
        if (uname.isNotEmpty) userNamesSet.add(uname);
      }
      final list = userNamesSet.toList()..sort();
      _userNames = ['-全て-'] + list;
      _initUserNamesFetched = true;
      if (_selectedUserName == null && _userNames.isNotEmpty) {
        _selectedUserName = '-全て-';
      }
    }
  }

  Widget _buildUserDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'ユーザー名で絞り込み',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      value:
          _selectedUserName ?? (_userNames.isNotEmpty ? _userNames[0] : null),
      items: _userNames
          .map(
            (name) => DropdownMenuItem<String>(
              value: name,
              child: Text(name == '-全て-' ? '全て' : name),
            ),
          )
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedUserName = val;
          _currentPage = 0;
        });
      },
    );
  }

  Widget _buildSalesTable(List<dynamic> paged) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('売上ID')),
          DataColumn(label: Text('注文日')),
          DataColumn(label: Text('ユーザー名')),
          DataColumn(label: Text('合計金額（税込）')),
        ],
        rows: [
          for (final sale in paged)
            DataRow(
              cells: [
                DataCell(
                  TextButton(
                    child: Text('${sale['id'] ?? ''}'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SalesDetailPage(
                          saleId: sale['id'] is int
                              ? sale['id']
                              : int.tryParse('${sale['id']}') ?? 0,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(_formatDateTime(sale['date']))),
                DataCell(
                  TextButton(
                    child: Text('${sale['user_name'] ?? ''}'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UsersDetail(
                          userId: sale['user_id'] is int
                              ? sale['user_id']
                              : int.tryParse('${sale['user_id']}') ?? 0,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(_calcWithTaxPriceString(sale['total']))),
              ],
            ),
        ],
      ),
    );
  }

  String _calcWithTaxPriceString(dynamic t) {
    int raw = 0;
    if (t is int) {
      raw = t;
    } else if (t != null) {
      raw = int.tryParse('$t') ?? 0;
    }
    final int taxed = _withTax(raw);
    return '${yenFormat.format(taxed)} 円';
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Flexible(child: _buildDateInput(context, true)),
          const SizedBox(width: 6),
          const Text('～'),
          const SizedBox(width: 6),
          Flexible(child: _buildDateInput(context, false)),
        ],
      ),
    );
  }

  Widget _buildDateInput(BuildContext context, bool isStart) {
    final pickedDate = isStart ? _startDate : _endDate;
    return Row(
      children: [
        Flexible(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: pickedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  if (isStart) {
                    _startDate = picked;
                  } else {
                    _endDate = picked;
                  }
                  _currentPage = 0;
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: isStart ? '開始日' : '終了日',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              child: Text(
                pickedDate != null ? formatJapaneseDate(pickedDate) : '',
              ),
            ),
          ),
        ),
      ],
    );
  }

  DateTime? _tryParseDateFromInput(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    try {
      if (RegExp(r'^\d{8}$').hasMatch(s)) {
        return DateTime(
          int.parse(s.substring(0, 4)),
          int.parse(s.substring(4, 6)),
          int.parse(s.substring(6, 8)),
        );
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s) ||
          RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(s)) {
        final fixed = s.replaceAll('/', '-');
        return DateTime.tryParse(fixed);
      }
      return DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
  }
}
