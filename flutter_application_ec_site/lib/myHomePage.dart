import 'package:flutter/material.dart'; // FlutterでUIを作るためのパッケージ

import 'test.dart';
import 'http.dart';
import 'login.dart';
import 'cart.dart';

// アプリの画面(UI) = MyHomePageウィジェット本体
class MyHomePage extends StatefulWidget {
  // タイトルを受け取る。このタイトルはアプリの上部バー(AppBar)に表示される。
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// 実際に表示やデータ取得の状態などを持つ_Stateクラス
class _MyHomePageState extends State<MyHomePage> {
  // 画面に表示する「商品(またはアイテム)一覧」を格納するリスト
  List<dynamic> items = [];
  // エラーが発生しているかどうか
  bool isError = false;
  // エラーが起きた時のメッセージを入れる
  String errorString = '';

  // ItemHttpClientのインスタンス
  final ItemHttpClient _itemHttpClient = ItemHttpClient();

  // 初期化関数。画面を作るとき最初に一度呼ばれる
  @override
  void initState() {
    super.initState();
    _fetchItems(); // 商品一覧を取得する関数を呼ぶ
  }

  // サーバーから商品一覧データを取得する非同期関数
  Future<void> _fetchItems() async {
    setState(() {
      isError = false;
      errorString = '';
    });

    try {
      final fetchedItems = await _itemHttpClient.fetchItems();
      setState(() {
        items = fetchedItems;
      });
    } on Exception catch (exception) {
      _onError(exception.toString());
    }
  }

  // エラーが発生したときに、状態(isError)とメッセージ(errorString)を更新する関数
  void _onError(String message) {
    debugPrint("Error: $message"); // デバッグ用にエラー内容を出力
    setState(() {
      isError = true;
      errorString = message;
    });
  }

  // 上から引っ張って再読み込みする時に呼ばれる関数
  Future<void> _reloadData() async {
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('新しいデータを取得しました');
    await _fetchItems();
  }

  // 画面そのもの(ウィジェット)を定義する関数。毎回画面が変わるごとに呼ばれる
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 30, color: Colors.green),
        ),
        centerTitle: true,
        leading: Icon(Icons.home),
        actions: [
          Icon(Icons.search),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).push(MaterialPageRoute(builder: (context) => Login()));
            },
            child: Text('ログイン'),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).push(MaterialPageRoute(builder: (context) => Cart()));
            },
            tooltip: 'Cartページへ',
          ),
        ],
        elevation: 10,
        backgroundColor: Colors.red,
        flexibleSpace: Image.network(
          'http://3.26.29.114/images/%E3%83%8E%E3%83%BC%E3%83%88/1129031014690ad52f20b671.42419074.png',
          fit: BoxFit.contain,
        ),
      ),
      body: isError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 16),
                  Text(errorString.isNotEmpty ? errorString : 'エラーが発生しました'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchItems,
                    child: const Text('再試行'),
                  ),
                  // test.dartに遷移するボタン（エラー時にも配置）
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).push(MaterialPageRoute(builder: (context) => Test()));
                    },
                    child: const Text('Testページへ'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _reloadData,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final String? imageUrl = item['image_url'] != null
                      ? '$imageBaseUrl${item['image_url']}'
                      : null;

                  final String name = item['name']?.toString() ?? '名称不明';
                  String? formattedPrice;
                  if (item['price'] != null) {
                    int? priceInt;
                    if (item['price'] is int) {
                      priceInt = item['price'];
                    } else if (item['price'] is String) {
                      priceInt = int.tryParse(item['price']);
                    }
                    if (priceInt != null) {
                      final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
                      String priceStr = priceInt.toString().replaceAllMapped(
                        reg,
                        (match) => ',',
                      );
                      formattedPrice = '¥$priceStr';
                    } else {
                      formattedPrice = '¥${item['price']}';
                    }
                  } else {
                    formattedPrice = null;
                  }
                  final String? description = item['description']?.toString();

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ItemImage(imageUrl: imageUrl),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (formattedPrice != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    formattedPrice,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(0, 0),
                                          blurRadius: 1.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (description != null &&
                                    description.trim().isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// 商品画像だけを表示するためのウィジェット
class _ItemImage extends StatelessWidget {
  final String? imageUrl;
  const _ItemImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const Icon(Icons.image);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 56,
        height: 56,
        color: Colors.grey[300],
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.network(
            imageUrl!,
            errorBuilder: (context, error, stackTrace) {
              debugPrint("Image load error: $error, stack: $stackTrace");
              return const Icon(Icons.image_not_supported);
            },
          ),
        ),
      ),
    );
  }
}
