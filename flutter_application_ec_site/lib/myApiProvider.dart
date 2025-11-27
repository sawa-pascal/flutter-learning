import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

part 'myApiProvider.g.dart';

// ============================================================================
// 定数定義
// ============================================================================

/// APIサーバーのベースURL（プロトコルなし）
const String apiBaseUrl = '3.25.105.3';

/// 画像リソースのベースURL
const String imageBaseUrl = 'http://3.25.105.3/images/';

/// HTTPステータスコード: 成功
const int httpStatusCodeSuccess = 200;

/// HTTPリクエストのタイムアウト時間（秒）
const Duration httpTimeoutDuration = Duration(seconds: 30);

// ============================================================================
// 共通関数
// ============================================================================

/// 共通のHTTPリクエストを処理するヘルパー関数
/// 
/// [request]: HTTPリクエストを実行する関数
/// [onSuccess]: 成功時のレスポンスを処理する関数
/// [key]: JSONレスポンスから取得するキー（省略可能）
/// 
/// 戻り値: 処理されたデータ
/// 
/// 例外: ネットワークエラーやサーバーエラーが発生した場合に例外をスロー
Future<T> _handleRequest<T>({
  required Future<http.Response> Function() request,
  required T Function(dynamic json) onSuccess,
  String? key,
}) async {
  final client = http.Client();
  try {
    // リクエストを実行（タイムアウト付き）
    final response = await request().timeout(httpTimeoutDuration);
    
    // ステータスコードをチェック
    if (response.statusCode == httpStatusCodeSuccess) {
      try {
        final jsonResponse = jsonDecode(response.body);
        
        // キーが指定されている場合は、そのキーの値を取得
        if (key != null && jsonResponse is Map) {
          return onSuccess(jsonResponse[key]);
        }
        return onSuccess(jsonResponse);
      } on FormatException catch (e) {
        throw Exception('JSON解析エラー: ${e.message}');
      }
    } else {
      throw Exception('サーバーエラー: HTTP ${response.statusCode}');
    }
  } on TimeoutException catch (e) {
    throw Exception('タイムアウトエラー: リクエストが時間内に完了しませんでした。${e.message}');
  } on SocketException catch (e) {
    throw Exception('ネットワークエラー: インターネット接続を確認してください。${e.message}');
  } on HttpException catch (e) {
    throw Exception('HTTPエラー: ${e.message}');
  } catch (e) {
    throw Exception('データ取得エラー: ${e.toString()}');
  } finally {
    // クライアントを確実にクローズ
    client.close();
  }
}

// ============================================================================
// API Provider定義
// ============================================================================

/// カテゴリー一覧を取得するProvider
/// 
/// サーバーからカテゴリーのリストを取得します。
/// 戻り値: カテゴリー情報のリスト
@riverpod
Future<List<dynamic>> categories(Ref ref) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().get(
      Uri.http(apiBaseUrl, '/api/categories/get_categories_list.php'),
    ),
    onSuccess: (json) => json is List ? json : [],
    key: 'items',
  );
}

/// 商品一覧を取得するProvider
/// 
/// サーバーから商品のリストを取得します。
/// 戻り値: 商品情報のリスト
@riverpod
Future<List<dynamic>> items(Ref ref) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().get(
      Uri.http(apiBaseUrl, '/api/items/get_items_list.php'),
    ),
    onSuccess: (json) => json is List ? json : [],
    key: 'items',
  );
}

/// ユーザーログインを実行するProvider
/// 
/// [email]: ユーザーのメールアドレス
/// [password]: ユーザーのパスワード
/// 
/// 戻り値: ログイン成功時のユーザー情報
@riverpod
Future<dynamic> login(
  Ref ref, {
  required String email,
  required String password,
}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().get(
      Uri.http(apiBaseUrl, '/api/get_user.php', {
        'email': email,
        'password': password,
      }),
    ),
    onSuccess: (json) => json ?? {},
    key: 'user',
  );
}

/// 購入処理を実行するProvider
/// 
/// [userId]: 購入するユーザーのID
/// [paymentId]: 支払い方法のID
/// [itemIds]: 購入する商品のIDリスト
/// [quantities]: 各商品の数量リスト（itemIdsと順序が一致している必要がある）
/// 
/// 戻り値: 購入処理の結果
@riverpod
Future<dynamic> purchase(
  Ref ref,
  int userId,
  int paymentId,
  List<int> itemIds,
  List<int> quantities,
) async {
  // バリデーション: 商品IDと数量のリストの長さが一致していることを確認
  if (itemIds.length != quantities.length) {
    throw Exception('商品IDと数量のリストの長さが一致していません');
  }
  
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/sales/purchase.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'payment_id': paymentId,
        'item_ids': itemIds,
        'quantities': quantities,
      }),
    ),
    onSuccess: (json) => json ?? {},
  );
}

/// 支払い方法一覧を取得するProvider
/// 
/// 戻り値: 支払い方法情報のリスト
@riverpod
Future<List<dynamic>> payments(Ref ref) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/sales/get_payment.php'),
      headers: {'Content-Type': 'application/json'},
    ),
    onSuccess: (json) => json is List ? json : [],
    key: 'payments',
  );
}

/// 購入履歴を取得するProvider
/// 
/// [user_id]: 購入履歴を取得するユーザーのID
/// 
/// 戻り値: 購入履歴情報のリスト
@riverpod
Future<List<dynamic>> purchaseHistory(Ref ref, int user_id) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/sales/get_purchase_history.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': user_id}),
    ),
    onSuccess: (json) => json is List ? json : [],
    key: 'purchase_history',
  );
}

/// ユーザー情報を更新するProvider
/// 
/// [id]: 更新するユーザーのID
/// [name]: ユーザー名
/// [email]: メールアドレス
/// [hashed_password]: ハッシュ化されたパスワード
/// [tel]: 電話番号
/// [prefecture_id]: 都道府県ID
/// [address]: 住所
/// 
/// 戻り値: 更新処理の結果
@riverpod
Future<dynamic> updateUser(
  Ref ref, {
  required int id,
  required String name,
  required String email,
  required String hashed_password,
  required String tel,
  required int prefecture_id,
  required String address,
}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/users/update_users.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'name': name,
        'email': email,
        'hashed_password': hashed_password,
        'tel': tel,
        'prefecture_id': prefecture_id,
        'address': address,
      }),
    ),
    onSuccess: (json) => json ?? {},
  );
}

/// パスワードを変更するProvider
/// 
/// [id]: パスワードを変更するユーザーのID
/// [newPassword]: 新しいパスワード（ハッシュ化済み）
/// 
/// 戻り値: 変更処理の結果メッセージ
@riverpod
Future<String> changePassword(
  Ref ref, {
  required int id,
  required String newPassword,
}) async {
  return _handleRequest<String>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/users/change_user_password.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'newPassword': newPassword}),
    ),
    onSuccess: (json) => json is String ? json : '',
    key: 'message',
  );
}

/// 都道府県一覧を取得するProvider
/// 
/// 戻り値: 都道府県情報のリスト
@riverpod
Future<List<dynamic>> prefectures(Ref ref) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().get(
      Uri.http(apiBaseUrl, '/api/get_prefectures_list.php'),
      headers: {'Content-Type': 'application/json'},
    ),
    onSuccess: (json) => json is List ? json : [],
    key: 'prefectures',
  );
}
