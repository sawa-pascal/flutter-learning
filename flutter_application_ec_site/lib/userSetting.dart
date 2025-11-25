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

  static const List<Map<String, dynamic>> _prefectures = [
    {"id": 1, "name": "北海道"},
    {"id": 2, "name": "青森県"},
    {"id": 3, "name": "岩手県"},
    {"id": 4, "name": "宮城県"},
    {"id": 5, "name": "秋田県"},
    {"id": 6, "name": "山形県"},
    {"id": 7, "name": "福島県"},
    {"id": 8, "name": "茨城県"},
    {"id": 9, "name": "栃木県"},
    {"id": 10, "name": "群馬県"},
    {"id": 11, "name": "埼玉県"},
    {"id": 12, "name": "千葉県"},
    {"id": 13, "name": "東京都"},
    {"id": 14, "name": "神奈川県"},
    {"id": 15, "name": "新潟県"},
    {"id": 16, "name": "富山県"},
    {"id": 17, "name": "石川県"},
    {"id": 18, "name": "福井県"},
    {"id": 19, "name": "山梨県"},
    {"id": 20, "name": "長野県"},
    {"id": 21, "name": "岐阜県"},
    {"id": 22, "name": "静岡県"},
    {"id": 23, "name": "愛知県"},
    {"id": 24, "name": "三重県"},
    {"id": 25, "name": "滋賀県"},
    {"id": 26, "name": "京都府"},
    {"id": 27, "name": "大阪府"},
    {"id": 28, "name": "兵庫県"},
    {"id": 29, "name": "奈良県"},
    {"id": 30, "name": "和歌山県"},
    {"id": 31, "name": "鳥取県"},
    {"id": 32, "name": "島根県"},
    {"id": 33, "name": "岡山県"},
    {"id": 34, "name": "広島県"},
    {"id": 35, "name": "山口県"},
    {"id": 36, "name": "徳島県"},
    {"id": 37, "name": "香川県"},
    {"id": 38, "name": "愛媛県"},
    {"id": 39, "name": "高知県"},
    {"id": 40, "name": "福岡県"},
    {"id": 41, "name": "佐賀県"},
    {"id": 42, "name": "長崎県"},
    {"id": 43, "name": "熊本県"},
    {"id": 44, "name": "大分県"},
    {"id": 45, "name": "宮崎県"},
    {"id": 46, "name": "鹿児島県"},
    {"id": 47, "name": "沖縄県"},
  ];

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー設定')),
      body: userModel == null
          ? const Center(child: Text('ユーザー情報が取得できませんでした'))
          : SingleChildScrollView(
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
                      items: _prefectures
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
                        // シンプルなバリデーション
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
            ),
    );
  }
}
