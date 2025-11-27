import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart'; // msApiProvider.dartを使用

class CategoriesCreatorPage extends ConsumerStatefulWidget {
  const CategoriesCreatorPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesCreatorPage> createState() => _CategoriesCreatorPageState();
}

class _CategoriesCreatorPageState extends ConsumerState<CategoriesCreatorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _displayOrderController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorText;
  String? _successText;

  @override
  void dispose() {
    _nameController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  Future<void> _submitCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
      _successText = null;
    });

    try {
      final String name = _nameController.text.trim();
      final String displayOrderStr = _displayOrderController.text.trim();
      final int displayOrder = int.parse(displayOrderStr);

      final result = await ref.read(createCategoriesProvider(
        name: name,
        display_order: displayOrder,
      ).future);

      if (result != null && (result['success'] == true || result['status'] == 'success')) {
        // カテゴリー登録が成功した場合、直前の画面に戻る
        if (mounted) {
          Navigator.of(context).pop(true); // trueを返して遷移元で再取得などが可能
        }
      } else {
        setState(() {
          _errorText = '登録に失敗しました: ${result?['message'] ?? '不明なエラー'}';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'カテゴリーの登録に失敗しました: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カテゴリー登録'),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 400,
            child: Card(
              margin: const EdgeInsets.all(24.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      if (_successText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _successText!,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'カテゴリ名',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'カテゴリ名を入力してください';
                          }
                          return null;
                        },
                        enabled: !_isSubmitting,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _displayOrderController,
                        decoration: const InputDecoration(
                          labelText: '表示順（数字）',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          // 数字(半角のみ)入力のみ許可
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '表示順を入力してください';
                          }
                          if (int.tryParse(value.trim()) == null) {
                            return '数字で入力してください';
                          }
                          return null;
                        },
                        enabled: !_isSubmitting,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(_isSubmitting ? '登録中...' : '登録する'),
                          onPressed: _isSubmitting ? null : _submitCategory,
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
