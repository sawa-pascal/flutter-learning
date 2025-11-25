import 'package:flutter/material.dart';
import 'models/userModel/userModel.dart';
import 'myApiProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordChange extends ConsumerStatefulWidget {
  const PasswordChange({Key? key}) : super(key: key);

  @override
  _PasswordChangeState createState() => _PasswordChangeState();
}

class _PasswordChangeState extends ConsumerState<PasswordChange> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword(UserModel userModel) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (userModel.hashed_password == null ||
        userModel.id == null ||
        userModel.hashed_password!.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ユーザー情報の取得に失敗しました';
      });
      return;
    }

    // 入力チェック
    if (currentPassword.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = '現在のパスワードを入力してください。';
      });
      return;
    }
    if (newPassword.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = '新しいパスワードを入力してください。';
      });
      return;
    }
    if (confirmPassword.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = '確認用パスワードを入力してください。';
      });
      return;
    }
    if (newPassword.length < 4) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'パスワードは4文字以上で入力してください。';
      });
      return;
    }
    if (confirmPassword.length < 4) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'パスワードは4文字以上で入力してください。';
      });
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() {
        _isLoading = false;
        _errorMessage = '新しいパスワードが一致しません。';
      });
      return;
    }
    if (currentPassword == newPassword) {
      setState(() {
        _isLoading = false;
        _errorMessage = '現在のパスワードと新しいパスワードが同じです。別のパスワードを入力してください。';
      });
      return;
    }

    // ローカルで現在のパスワードが一致するかチェック
    final savedPassword = userModel.hashed_password!;
    if (currentPassword != savedPassword) {
      setState(() {
        _isLoading = false;
        _errorMessage = '現在のパスワードが正しくありません。';
      });
      return;
    }

    // APIでパスワード変更リクエスト実行＋userModelProviderを更新
    try {
      final userId = userModel.id!;
      final msg = await ref.read(
        changePasswordProvider(id: userId, newPassword: newPassword).future,
      );

      // userModelを新しいパスワードで更新
      final userModelNotifier = ref.read(userModelProvider.notifier);
      userModelNotifier.state = userModel.copyWith(
        hashed_password: newPassword,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg is String && msg.isNotEmpty ? msg : 'パスワードが変更されました。',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'パスワードの変更に失敗しました: $e';
        _successMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('パスワード変更')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      if (_successMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: const InputDecoration(
                          labelText: '現在のパスワード',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? '現在のパスワードを入力してください'
                            : value.length < 4
                            ? 'パスワードは4文字以上で入力してください'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: const InputDecoration(
                          labelText: '新しいパスワード',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? '新しいパスワードを入力してください'
                            : value.length < 4
                            ? 'パスワードは4文字以上で入力してください'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: '新しいパスワード（確認）',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? '確認用パスワードを入力してください'
                            : value.length < 4
                            ? 'パスワードは4文字以上で入力してください'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    if (userModel != null) {
                                      _changePassword(userModel);
                                    } else {
                                      setState(() {
                                        _errorMessage = 'ユーザー情報の取得に失敗しました';
                                      });
                                    }
                                  }
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('パスワードを変更する'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
