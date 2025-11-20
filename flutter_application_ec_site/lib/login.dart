import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/userModel/userModel.dart';
import 'myApiProvider.dart';

/// ログイン画面のウィジェット（RiverpodのConsumerStatefulWidgetを使用）
class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  // フォームの状態管理
  final _formKey = GlobalKey<FormState>();
  // メールアドレス入力用コントローラー
  final _emailController = TextEditingController();
  // パスワード入力用コントローラー
  final _passwordController = TextEditingController();
  // パスワード表示・非表示の切り替え状態
  bool _obscureText = true;
  // ローディング中状態フラグ
  bool _isLoading = false;

  @override
  void dispose() {
    // コントローラーを破棄
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ログイン処理
  Future<void> _login() async {
    // 入力が正しい場合のみ処理継続
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // APIを通じてログインし、ユーザー情報(JSON)を取得
      final userJson = await ref.read(
        loginProvider(
          email: _emailController.text,
          password: _passwordController.text,
        ).future,
      );

      setState(() => _isLoading = false);

      // 正常にユーザー情報が取得できた場合
      if (_isValidUserJson(userJson)) {
        // JSONからUserModelを生成してProviderに格納
        final userModel = UserModel.fromJson(userJson);
        ref.read(userModelProvider.notifier).state = userModel;

        // ログイン成功メッセージを表示
        _showSnackBar('ログイン成功');
        Navigator.pop(context);
      } else {
        // ログイン失敗時(ユーザー情報が取得できなかった場合)
        _showSnackBar('ログイン失敗');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // エラー内容と共に失敗メッセージを表示
      _showSnackBar('ログイン失敗: $e');
    }
  }

  /// ユーザーJSONが有効かどうかを判定
  bool _isValidUserJson(dynamic json) {
    return json != null &&
        json is Map<String, dynamic> &&
        json['id'] != null;
  }

  /// スナックバーでメッセージを表示
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// メールアドレス入力欄ウィジェット
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'メールアドレス',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'メールアドレスを入力してください';
        }
        // 簡易なメール形式チェック
        if (!RegExp(r'^[^@]+@[^@]+').hasMatch(value)) {
          return '有効なメールアドレスを入力してください';
        }
        return null;
      },
    );
  }

  /// パスワード入力欄ウィジェット
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'パスワード',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          // パスワード表示・非表示を切り替え
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'パスワードを入力してください';
        }
        if (value.length < 4) {
          return '4文字以上で入力してください';
        }
        return null;
      },
    );
  }

  /// ログインボタンウィジェット
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        child: const Text('ログイン'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // メールアドレス入力欄
                _buildEmailField(),
                const SizedBox(height: 16),
                // パスワード入力欄
                _buildPasswordField(),
                const SizedBox(height: 24),
                // ローディング中はインジケータを、それ以外はログインボタンを表示
                _isLoading
                    ? const CircularProgressIndicator()
                    : _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
