import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';

class UsersEditPage extends ConsumerStatefulWidget {
  final int userId;

  const UsersEditPage({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<UsersEditPage> createState() => _UsersEditPageState();
}

class _UsersEditPageState extends ConsumerState<UsersEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _telController;
  int? _prefectureId;
  late TextEditingController _addressController;

  bool _initializing = true;

  // Prefectures data
  List<dynamic> _prefectures = [];

  String _hashedPassword = '';

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _telController = TextEditingController();
    _addressController = TextEditingController();
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    setState(() {
      _initializing = true;
    });
    await _fetchPrefectures();
    await _fetchUserData();
    setState(() {
      _initializing = false;
    });
  }

  Future<void> _fetchPrefectures() async {
    try {
      _prefectures = await ref.read(prefecturesProvider.future);
    } catch (e) {
      _showSnackBar('都道府県リストの取得に失敗しました: $e');
      _prefectures = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final userMap = await ref.read(
        usersListProvider(id: widget.userId).future,
      );
      final user = userMap['users'] ?? {};
      // Fix: user may actually be a List, not a Map. But in this code/data shape, assume Map.
      _nameController.text = user['name'] ?? '';
      _emailController.text = user['email'] ?? '';
      _telController.text = user['tel'] ?? '';
      final prefIdRaw = user['prefecture_id'];
      if (prefIdRaw != null && prefIdRaw.toString().isNotEmpty) {
        _prefectureId = int.tryParse(prefIdRaw.toString());
      } else {
        _prefectureId = null;
      }
      _addressController.text = user['address'] ?? '';
      // パスワードは取得したものを使う
      _hashedPassword = user['hashed_password'] ?? '';
    } catch (e) {
      _showSnackBar('ユーザー情報の取得に失敗しました: $e');
    }
  }

  Future<void> _handleSave(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(
        updateUserProvider(
          id: widget.userId,
          name: _nameController.text,
          email: _emailController.text,
          tel: _telController.text,
          prefecture_id: _prefectureId ?? 0,
          address: _addressController.text,
          hashed_password: _hashedPassword,
        ).future,
      );

      if ((result['success'] ?? false) == true) {
        _showSnackBar('更新しました');
        Navigator.of(context).pop(true);
      } else {
        _showSnackBar(result['message'] ?? '更新に失敗しました');
      }
    } catch (e) {
      _showSnackBar('エラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー編集')),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: '名前'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '名前を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'メールアドレス'),
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
                    const SizedBox(height: 18),
                    // パスワード入力欄は表示しない
                    TextFormField(
                      controller: _telController,
                      decoration: const InputDecoration(labelText: '電話番号'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '電話番号を入力してください';
                        }
                        // Optionally, could check for valid phone format here
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<int>(
                      value: _prefectureId,
                      items: _prefectures.map((pref) {
                        // Defensive programming: handle id as int
                        final id = pref['id'];
                        String? name;
                        if (pref.containsKey('name')) {
                          name = pref['name']?.toString();
                        }
                        return DropdownMenuItem<int>(
                          value: id is int ? id : int.tryParse(id.toString()),
                          child: Text(name ?? '都道府県$id'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _prefectureId = val;
                        });
                      },
                      decoration: const InputDecoration(labelText: '都道府県'),
                      validator: (val) => val == null ? '都道府県を選択してください' : null,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: '住所'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '住所を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _handleSave(ref),
                                icon: const Icon(Icons.save),
                                label: const Text('保存'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.cancel),
                                label: const Text('キャンセル'),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}