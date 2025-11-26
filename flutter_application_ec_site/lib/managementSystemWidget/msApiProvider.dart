import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

part 'msApiProvider.g.dart';

// ============================================================================
// 定数定義
// ============================================================================

/// APIサーバーのベースURL（プロトコルなし）
const String apiBaseUrl = '3.107.37.75';

/// 画像リソースのベースURL
const String imageBaseUrl = 'http://3.107.37.75/images/';

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

@riverpod
Future<dynamic> createCategories(
  Ref ref, {
  required String name,
  required String display_order,
}) async {
  return _handleRequest<dynamic>(
    request: () => http.Client().post(
      Uri.http(apiBaseUrl, '/api/categories/create_categories.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'display_order': display_order,
      }),
    ),
    onSuccess: (json) => json ?? {},
  );
}