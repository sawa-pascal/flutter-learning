import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

part 'myApiProvider.g.dart';

/// サーバーアドレスと画像のベースURL
const String apiBaseUrl = '3.107.37.75';
const String imageBaseUrl = 'http://3.107.37.75/images/';

/// 共通の HTTP リクエストを処理するヘルパー関数
Future<T> _handleRequest<T>({
  required Future<http.Response> Function() request,
  required T Function(dynamic json) onSuccess,
  String? key,
}) async {
  final client = http.Client();
  try {
    final response = await request();
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (key != null) {
        return onSuccess(jsonResponse[key]);
      }
      return onSuccess(jsonResponse);
    } else {
      throw Exception('サーバーエラー: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    throw Exception("ネットワークエラー: ${e.toString()}");
  } catch (e) {
    throw Exception("データ取得エラー: ${e.toString()}");
  } finally {
    client.close();
  }
}

@riverpod
Future<List<dynamic>> categories(Ref ref) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().get(
      Uri.http(apiBaseUrl, '/api/categories/get_categories_list.php'),
    ),
    onSuccess: (json) => json ?? [],
    key: 'items',
  );
}

@riverpod
Future<List<dynamic>> items(Ref ref) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().get(
      Uri.http(apiBaseUrl, '/api/items/get_items_list.php'),
    ),
    onSuccess: (json) => json ?? [],
    key: 'items',
  );
}

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
    onSuccess: (json) => json ?? [],
    key: 'user',
  );
}

@riverpod
Future<dynamic> purchase(
  Ref ref,
  int userId,
  int paymentId,
  List<int> itemIds,
  List<int> quantities,
) async {
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
    onSuccess: (json) => json,
  );
}

@riverpod
Future<List<dynamic>> payments(Ref ref) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/sales/get_payment.php'),
    ),
    onSuccess: (json) => json ?? [],
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
    onSuccess: (json) => json ?? [],
    key: 'purchase_history',
  );
}

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
    onSuccess: (json) => json ?? '',
  );
}

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
    onSuccess: (json) => json ?? '',
    key: 'message',
  );
}

@riverpod
Future<List<dynamic>> prefectures(Ref ref) async {
  return _handleRequest<List<dynamic>>(
    request: () => http.Client().get(
      Uri.http(apiBaseUrl, '/api/get_prefectures_list.php'),
      headers: {'Content-Type': 'application/json'},
    ),
    onSuccess: (json) => json ?? [],
    key: 'prefectures',
  );
}
