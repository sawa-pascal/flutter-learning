import 'package:flutter/material.dart';

/// 汎用ページ送りウィジェット（ページ数が多い場合もコンパクト表示）
class Pagination extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onPageChanged;

  const Pagination({
    Key? key,
    required this.currentPage,
    required this.pageCount,
    required this.onPageChanged,
  }) : super(key: key);

  List<_PageButton> _buildPages() {
    List<_PageButton> list = [];

    // always show the first page if not in 0,1
    if (currentPage > 1) {
      list.add(_PageButton(index: 0));
      if (currentPage > 2) {
        list.add(_PageButton.ellipsis());
      }
    }

    // 前後1ページ分表示
    int start = currentPage - 1;
    int end = currentPage + 1;
    start = start < 0 ? 0 : start;
    end = end > pageCount - 1 ? pageCount - 1 : end;

    for (int i = start; i <= end; i++) {
      if (i == 0 && currentPage > 1) continue; // already added
      if (i == pageCount - 1 && currentPage < pageCount - 2) continue; // will be added later
      list.add(_PageButton(index: i));
    }

    // always show the last page if not near the end
    if (currentPage < pageCount - 2) {
      if (currentPage < pageCount - 3) {
        list.add(_PageButton.ellipsis());
      }
      list.add(_PageButton(index: pageCount - 1));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();
    final pages = _buildPages();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2), // 横paddingもせまく
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.first_page),
              onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
              tooltip: '最初のページ',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.chevron_left),
              onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
              tooltip: '前のページ',
            ),
          ),
          ...pages.map((btn) {
            if (btn.isEllipsis) {
              // 間隔をより狭く
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.5),
                child: SizedBox(
                  width: 20,
                  child: Center(child: Text('…', style: TextStyle(fontSize: 14))),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: SizedBox(
                height: 30,
                width: 30,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: currentPage == btn.index
                        ? Colors.blueAccent.withOpacity(0.15)
                        : null,
                    side: BorderSide(
                      color: currentPage == btn.index ? Colors.blue : Colors.grey.shade400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: currentPage == btn.index ? null : () => onPageChanged(btn.index!),
                  child: Text(
                    '${btn.index! + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      color: currentPage == btn.index ? Colors.blue : null,
                      fontWeight: currentPage == btn.index ? FontWeight.bold : null,
                      height: 1,
                    ),
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.chevron_right),
              onPressed: currentPage < (pageCount - 1) ? () => onPageChanged(currentPage + 1) : null,
              tooltip: '次のページ',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.last_page),
              onPressed: currentPage < (pageCount - 1) ? () => onPageChanged(pageCount - 1) : null,
              tooltip: '最後のページ',
            ),
          ),
        ],
      ),
    );
  }
}

class _PageButton {
  final int? index;
  final bool isEllipsis;

  _PageButton({required this.index}) : isEllipsis = false;
  _PageButton.ellipsis()
      : index = null,
        isEllipsis = true;
}
