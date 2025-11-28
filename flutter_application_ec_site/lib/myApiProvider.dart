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
const String apiBaseUrl = '3.26.165.82';

/// 画像リソースのベースURL
const String imageBaseUrl = 'http://3.26.165.82/images/';

/// HTTPステータスコード: 成功
const int httpStatusCodeSuccess = 200;

/// HTTPリクエストのタイムアウト時間（秒）
const Duration httpTimeoutDuration = Duration(seconds: 30);

// ============================================================================
// 共通関数
// ============================================================================

Future<T> _handleRequest<T>({
  required Future<http.Response> Function() request,
  required T Function(dynamic json) onSuccess,
  String? key,
}) async {
  final client = http.Client();
  try {
    final response = await request().timeout(httpTimeoutDuration);
    if (response.statusCode == httpStatusCodeSuccess) {
      try {
        final jsonResponse = jsonDecode(response.body);
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
    client.close();
  }
}

// ============================================================================
// API Provider定義 (phpファイルに対応)
// ============================================================================

// ========= /api/categories/ =========

@riverpod
Future<List<dynamic>> categories(Ref ref, {int? id}) async {
  final uri = id != null
      ? Uri.http(apiBaseUrl, '/api/categories/get_categories_list.php', {
          'id': id.toString(),
        })
      : Uri.http(apiBaseUrl, '/api/categories/get_categories_list.php');
  return _handleRequest<List<dynamic>>(
    request: () =>
        http.Client().get(uri, headers: {'Content-Type': 'application/json'}),
    onSuccess: (json) => json is List ? json : [],
    key: 'items',
  );
}

@riverpod
Future<dynamic> createCategories(
  Ref ref, {
  required String name,
  required int display_order,
}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/categories/create_categories.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'display_order': display_order}),
    ),
    onSuccess: (json) => json ?? {},
  );
}

@riverpod
Future<dynamic> updateCategories(
  Ref ref, {
  required int id,
  required String name,
  required int display_order,
}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/categories/update_categories.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'name': name,
        'display_order': display_order,
      }),
    ),
    onSuccess: (json) => json ?? {},
  );
}

@riverpod
Future<dynamic> deleteCategories(Ref ref, {required int id}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/categories/delete_categories.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    ),
    onSuccess: (json) => json ?? {},
  );
}

// ========= /api/items/ =========

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

@riverpod
Future<dynamic> createItems(
  Ref ref, {
  required String name,
  required int category_id,
  required int price,
  required int stock,
  required String description,
  required String image_url,
}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/items/create_items.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'category_id': category_id,
        'price': price,
        'stock': stock,
        'description': description,
        'image_url': image_url,
      }),
    ),
    onSuccess: (json) => json ?? {},
  );
}

@riverpod
Future<dynamic> updateItems(
  Ref ref, {
  required int id,
  required String name,
  required int category_id,
  required int price,
  required int stock,
  required String description,
  required String image_url,
  String? origin_image_url,
}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/items/update_items.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'name': name,
        'category_id': category_id,
        'price': price,
        'stock': stock,
        'description': description,
        'image_url': image_url,
        'origin_image_url': origin_image_url ?? '',
      }),
    ),
    onSuccess: (json) => json ?? {},
  );
}

@riverpod
Future<dynamic> deleteItems(Ref ref, {required int id}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/items/delete_items.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    ),
    onSuccess: (json) => json ?? {},
  );
}

@riverpod
Future<dynamic> uploadItemImage(
  Ref ref, {
  required String categoryName,
  String? imageUrl,
  required List<int> imageBytes,
}) async {
  // マルチパートで画像データを送信
  var uri = Uri.http(apiBaseUrl, '/api/items/upload_item_image.php');
  var request = http.MultipartRequest('POST', uri);
  request.fields['category_name'] = categoryName;
  if (imageUrl != null) {
    request.fields['image_url'] = imageUrl; // 既存画像URL(空OK)
  }

  // 画像ファイル名を指定（デフォルト名をつけて送るとサーバー側で$_FILES['upfile']['name']が空にならない）
  request.files.add(
    http.MultipartFile.fromBytes(
      'upfile',
      imageBytes,
      filename: 'upload.png', // または 'image.jpg'
      contentType: http.MediaType('image', 'png'), // contentTypeは省略可能だが付けると確実
    ),
  );

  final streamedResponse = await request.send().timeout(httpTimeoutDuration);
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == httpStatusCodeSuccess) {
    try {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } on FormatException catch (e) {
      throw Exception('JSON解析エラー: ${e.message}');
    }
  } else {
    throw Exception('サーバーエラー: HTTP ${response.statusCode}');
  }
}

// ========= /api/sales/ =========

@riverpod
Future<dynamic> purchase(
  Ref ref,
  int userId,
  int paymentId,
  List<int> itemIds,
  List<int> quantities,
) async {
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

@riverpod
Future<Map<String, dynamic>> salesList(Ref ref) async {
  return _handleRequest<Map<String, dynamic>>(
    request: () => http.Client().get(
      Uri.http(apiBaseUrl, '/api/sales/get_sales_list.php'),
      headers: {'Content-Type': 'application/json'},
    ),
    onSuccess: (json) => json is Map<String, dynamic> ? json : {},
  );
}

/// 注文詳細アイテム一覧取得
@riverpod
Future<List<dynamic>> saleItems(Ref ref, {required int saleId}) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/sales/get_sale_items.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sale_id': saleId}),
    ),
    onSuccess: (json) => json is List ? json : [],
    key: 'sale_items'
  );
}

// ========= /api/users/ =========

// ユーザー一覧取得
@riverpod
Future<Map<String, dynamic>> usersList(Ref ref, {int? id}) async {
  return _handleRequest<Map<String, dynamic>>(
    request: () => http.Client().get(
      id != null
          ? Uri.http(apiBaseUrl, '/api/users/get_users_list.php', {
              'id': id.toString(),
            })
          : Uri.http(apiBaseUrl, '/api/users/get_users_list.php'),
      headers: {'Content-Type': 'application/json'},
    ),
    onSuccess: (json) => json is Map<String, dynamic> ? json : {},
  );
}

// ユーザー新規登録
@riverpod
Future<dynamic> createUsers(
  Ref ref, {
  required String name,
  required String email,
  required String hashed_password,
  required String tel,
  required int prefecture_id,
  required String address,
}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/users/create_users.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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

// ユーザー情報更新
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

// ユーザー削除
@riverpod
Future<dynamic> deleteUser(Ref ref, {required int id}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/users/delete_users.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    ),
    onSuccess: (json) => json ?? {},
  );
}

// パスワード変更
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

// ========= /api/management_signin.php =========

@riverpod
Future<dynamic> managementSignin(
  Ref ref, {
  required String name,
  required String hashed_password,
}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().get(
      Uri.http(apiBaseUrl, '/api/management_signin.php', {
        'name': name,
        'hashed_password': hashed_password,
      }),
    ),
    onSuccess: (json) => json ?? {},
    key: 'user',
  );
}

// ========= /api/get_user.php =========

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

// ========= /api/get_prefectures_list.php =========

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
