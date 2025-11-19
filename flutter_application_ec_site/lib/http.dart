import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

//https://dev.classmethod.jp/articles/flutter-rest-api/
//↑FlutterパッケージのHTTPでAPI通信を行う方法
//https://note.com/hatchoutschool/n/n67eb3d9106f1
//↑ListViewで表示するWidgetを下に引っ張ってデータを更新する方法
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List items = [];
  bool isError = false;
  String errorString = '';

  Future<void> getData() async {
    // https://www.youtube.com/watch?v=2tBbC1rZo3Q&t=489s
    // HTTP：ブラウザとサーバーの間で通信を行うための規格
    // GETメソッド：データをちょうだい→パラメーターはURLに含める

    // 第一引数：Authority（どのWEBサーバーか）
    // 第二引数：Path（そのサーバーのどこのことを指すか）
    // 第三引数：Query
    try {
      // 例（正しい書き方）:
      var response = await http.get(
        Uri.http('3.26.29.114', '/api/items/get_items_list.php'),
      );
      // 2. 問題がなければ、Json型に変換したデータを格納
      var jsonResponse = _response(response);
      // 3. 本の情報をリスト形式でデータを格納
      setState(() {
        items = jsonResponse['items'];
      });
      // throw Exception();
    } on SocketException catch (socketException) {
      // ソケット操作が失敗した時にスローされる例外
      debugPrint("Error: ${socketException.toString()}");
      isError = true;
    } on Exception catch (exception) {
      // statusCode: 200以外の場合
      debugPrint("Error: ${exception.toString()}");
      isError = true;
    } catch (_) {
      debugPrint("Error: 何かしらの問題が発生しています");
      isError = true;
    }
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        // 400 Bad Request : 一般的なクライアントエラー
        throw Exception('一般的なクライアントエラーです');
      case 401:
        // 401 Unauthorized : アクセス権がない、または認証に失敗
        throw Exception('アクセス権限がない、または認証に失敗しました');
      case 403:
        // 403 Forbidden ： 閲覧権限がないファイルやフォルダ
        throw Exception('閲覧権限がないファイルやフォルダです');
      case 500:
        // 500 何らかのサーバー内で起きたエラー
        throw Exception('何らかのサーバー内で起きたエラーです');
      default:
        // それ以外の場合
        throw Exception('何かしらの問題が発生しています');
    }
  }

  //ListViewで表示するWidgetを下に引っ張ってデータを更新する
  Future _loadData() async {
    //Future.delay()を使用して擬似的に非同期処理を表現
    await Future.delayed(Duration(seconds: 2));

    print('新しいデータを取得しました');

    setState(() {
      //新しいデータを挿入して表示
      getData();
    });
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Sample')),
      body: isError
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                print('データをリロード中');
                await _loadData();
              },
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];
                  // item['image_url'] を使って画像表示
                  String? imageUrl = item['image_url'] != null
                      ? 'http://3.26.29.114/images/${item['image_url']}'
                      : null;

                  // URLの値をデバッグ出力してみる
                  print("imageUrl: $imageUrl");

                  return Card(
                    child: ListTile(
                      leading: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey[300],
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Image.network(
                                    imageUrl,
                                    errorBuilder: (context, error, stackTrace) {
                                      // 詳しいエラー内容も表示
                                      print(
                                          "Image load error: $error, stack: $stackTrace");
                                      return Icon(Icons.image_not_supported);
                                    },
                                  ),
                                ),
                              ),
                            )
                          : Icon(Icons.image),
                      title: Text(item['name']?.toString() ?? 'No Name'),
                      subtitle: Text(item.toString()),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
