import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';

class UsersCreator extends ConsumerStatefulWidget {
  const UsersCreator({Key? key}) : super(key: key);

  @override
  ConsumerState<UsersCreator> createState() => _UsersCreatorState();
}

class _UsersCreatorState extends ConsumerState<UsersCreator> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isAdmin = false;
  bool _isSubmitting = false;
  String? _apiError;

  int? _selectedPrefectureId;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _apiError = null;
      });

      try {
        final result = await ref.read(
          createUsersProvider(
            name: _nameController.text,
            email: _emailController.text,
            hashed_password: _passwordController.text,
            tel: _telController.text,
            prefecture_id: _selectedPrefectureId!,
            address: _addressController.text,
          ).future,
        );

        setState(() {
          _isSubmitting = false;
        });

        if (result != null && result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ユーザーを登録しました')),
            );
            Navigator.of(context).pop();
          }
        } else {
          setState(() {
            _apiError = result?['message'] ?? 'ユーザー登録に失敗しました';
          });
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
          _apiError = 'サーバーエラー: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefecturesAsync = ref.watch(prefecturesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー新規登録'),
      ),
      body: prefecturesAsync.when(
        data: (prefList) {
          final List<Map<String, dynamic>> prefectures = prefList is List
              ? prefList.cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_apiError != null) ...[
                    Text(
                      _apiError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '氏名',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '氏名は必須です';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'メールアドレス',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'メールアドレスは必須です';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+').hasMatch(value)) {
                        return '有効なメールアドレスを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'パスワード',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'パスワードは必須です';
                      }
                      if (value.length < 4) {
                        return '4文字以上で入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telController,
                    decoration: const InputDecoration(
                      labelText: '電話番号',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '電話番号は必須です';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedPrefectureId,
                    decoration: const InputDecoration(
                      labelText: '都道府県',
                      border: OutlineInputBorder(),
                    ),
                    items: prefectures
                        .map<DropdownMenuItem<int>>((e) => DropdownMenuItem(
                              value: e['id'] as int,
                              child: Text(e['name'] as String),
                            ))
                        .toList(),
                    onChanged: (int? value) {
                      setState(() {
                        _selectedPrefectureId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return '都道府県を選択してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: '住所',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '住所は必須です';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('登録'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('都道府県情報取得エラー: $err'),
        ),
      ),
    );
  }
}
