// @riverpod アノテーションは `riverpod_annotation` をインポートして使います
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// コード生成を実行するために、 `part '{ファイル名}.g.dart';` を忘れずに書きましょう
part 'myApiProvider.g.dart';

/// サーバーアドレスと画像のベースURL
const String apiBaseUrl = '3.26.29.114';
const String imageBaseUrl = 'http://3.26.29.114/images/';

@riverpod
Future<List<dynamic>> categories(Ref ref) async {
  final client = http.Client();
  try {
    final response = await client.get(
      Uri.http(apiBaseUrl, '/api/categories/get_categories_list.php'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['items'] ?? [];
    } else {
      throw Exception('サーバーエラー: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    throw Exception("ネットワークエラー: ${e.toString()}");
  } on Exception catch (e) {
    throw Exception("データ取得エラー: ${e.toString()}");
  } finally {
    client.close();
  }
}

@riverpod
Future<List<dynamic>> items(Ref ref) async {
  final client = http.Client();
  try {
    final response = await client.get(
      Uri.http(apiBaseUrl, '/api/items/get_items_list.php'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['items'] ?? [];
    } else {
      throw Exception('サーバーエラー: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    throw Exception("ネットワークエラー: ${e.toString()}");
  } on Exception catch (e) {
    throw Exception("データ取得エラー: ${e.toString()}");
  } finally {
    client.close();
  }
}

@riverpod
Future<dynamic> login(
  Ref ref, {
  required String email,
  required String password,
}) async {
  final client = http.Client();
  try {
    final response = await client.get(
      Uri.http(apiBaseUrl, '/api/get_user.php', {
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['user'] ?? [];
    } else {
      throw Exception('サーバーエラー: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    throw Exception("ネットワークエラー: ${e.toString()}");
  } on Exception catch (e) {
    throw Exception("データ取得エラー: ${e.toString()}");
  } finally {
    client.close();
  }
}

@riverpod
Future<dynamic> purchase(
  Ref ref,
  int userId,
  int paymentId,
  List<int> itemIds,
  List<int> quantities,
) async {
  final client = http.Client();
  try {
    final response = await client.post(
      Uri.http(apiBaseUrl, '/api/sales/purchase.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'payment_id': paymentId,
        'item_ids': itemIds,
        'quantities': quantities,
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception('サーバーエラー: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    throw Exception("ネットワークエラー: ${e.toString()}");
  } on Exception catch (e) {
    throw Exception("データ取得エラー: ${e.toString()}");
  } finally {
    client.close();
  }
}

@riverpod
Future<dynamic> payments(Ref ref) async {
  final client = http.Client();
  try {
    final response = await client.post(
      Uri.http(apiBaseUrl, '/api/sales/get_payment.php'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['payments'] ?? [];
    } else {
      throw Exception('サーバーエラー: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    throw Exception("ネットワークエラー: ${e.toString()}");
  } on Exception catch (e) {
    throw Exception("データ取得エラー: ${e.toString()}");
  } finally {
    client.close();
  }
}
