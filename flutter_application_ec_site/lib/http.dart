import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// サーバーアドレスと画像のベースURL
const String apiBaseUrl = '3.26.29.114';
const String imageBaseUrl = 'http://3.26.29.114/images/';

/// HTTP通信をラップしたクラス
class ItemHttpClient {
  final http.Client _client;

  ItemHttpClient({http.Client? client}) : _client = client ?? http.Client();

  /// 商品一覧を取得
  Future<List<dynamic>> fetchItems() async {
    try {
      final response = await _client.get(
        Uri.http(apiBaseUrl, '/api/items/get_items_list.php'),
      );
      final jsonResponse = _processResponse(response);
      return jsonResponse['items'] ?? [];
    } on SocketException catch (e) {
      throw Exception("ネットワークエラー: ${e.toString()}");
    } on Exception catch (e) {
      throw Exception("データ取得エラー: ${e.toString()}");
    } catch (_) {
      throw Exception("予期しないエラーが発生しました");
    }
  }

  /// サーバーのレスポンスを処理し、エラーなら例外を投げる
  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 400:
        throw Exception('一般的なクライアントエラーです');
      case 401:
        throw Exception('アクセス権限がない、または認証に失敗しました');
      case 403:
        throw Exception('閲覧権限がないファイルやフォルダです');
      case 500:
        throw Exception('何らかのサーバー内で起きたエラーです');
      default:
        throw Exception('何かしらの問題が発生しています');
    }
  }
}
