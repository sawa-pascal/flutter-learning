import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/userModel/userModel.dart';
import 'myApiProvider.dart';

class UserSetting extends ConsumerStatefulWidget {
  const UserSetting({Key? key}) : super(key: key);

  @override
  ConsumerState<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends ConsumerState<UserSetting> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _telController;
  int? _prefectureId;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    final userModel = ref.read(userModelProvider);
    _nameController = TextEditingController(text: userModel?.name ?? '');
    _emailController = TextEditingController(text: userModel?.email ?? '');
    _addressController = TextEditingController(text: userModel?.address ?? '');
    _telController = TextEditingController(text: userModel?.tel ?? '');
    _prefectureId = userModel?.prefecture_id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _telController.dispose();
    super.dispose();
  }

  Future<void> _updateUser(UserModel userModel) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final updatedJson = await ref.read(
        updateUserProvider(
          id: userModel.id,
          name: _nameController.text,
          email: _emailController.text,
          address: _addressController.text,
          tel: _telController.text,
          prefecture_id: _prefectureId ?? 0,
          hashed_password: userModel.hashed_password ?? '',
        ).future,
      );

      if (updatedJson != null && updatedJson["success"]) {
        // 成功時
        // ユーザーデータも更新
        final updatedUser = userModel.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          address: _addressController.text,
          tel: _telController.text,
          prefecture_id: _prefectureId ?? 0,
        );
        ref.read(userModelProvider.notifier).state = updatedUser;
        setState(() {
          _successMessage = updatedJson['message'];
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(updatedJson['message'])));
        Navigator.pop(context);
      } else if (updatedJson != null && updatedJson.containsKey('message')) {
        setState(() {
          _errorMessage = updatedJson['message'];
        });
      } else {
        setState(() {
          _errorMessage = 'ユーザー情報の更新に失敗しました';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'エラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userModelProvider);

    final prefecturesAsyncValue = ref.watch(prefecturesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー設定')),
      body: userModel == null
          ? const Center(child: Text('ユーザー情報が取得できませんでした'))
          : prefecturesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('都道府県リストの取得に失敗しました: $error')),
              data: (prefecturesData) {
                List<dynamic> prefectures =
                    (prefecturesData as List<dynamic>)
                        .whereType<Map<String, dynamic>>()
                        .toList();
                // Prefectureが空の場合のファールセーフ
                if (prefectures.isEmpty) {
                  return const Center(child: Text('都道府県情報が取得できませんでした'));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        if (_successMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'お名前',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'お名前を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'メールアドレス',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'メールアドレスを入力してください';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+').hasMatch(value)) {
                              return '有効なメールアドレスを入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: '都道府県',
                            border: OutlineInputBorder(),
                          ),
                          value: _prefectureId == 0 ? null : _prefectureId,
                          items: prefectures
                              .map(
                                (pref) => DropdownMenuItem<int>(
                                  value: pref['id'] as int,
                                  child: Text(pref['name']),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _prefectureId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value == 0) {
                              return '都道府県を選択してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: '住所',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '住所を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _telController,
                          decoration: const InputDecoration(
                            labelText: '電話番号',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '電話番号を入力してください';
                            }
                            if (!RegExp(
                              r'^\d{2,4}-?\d{2,4}-?\d{3,4}$',
                            ).hasMatch(value)) {
                              return '有効な電話番号を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (userModel != null) {
                                      _updateUser(userModel);
                                    }
                                  },
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('保存する'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
