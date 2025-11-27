import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';

class CategoriesEditPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> category;

  const CategoriesEditPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  ConsumerState<CategoriesEditPage> createState() => _CategoriesEditPageState();
}

class _CategoriesEditPageState extends ConsumerState<CategoriesEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _displayOrderController;

  bool _isSubmitting = false;
  String? _errorText;
  String? _successText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category['name']?.toString() ?? '');
    _displayOrderController = TextEditingController(text: widget.category['display_order']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
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

      // カテゴリID
      final int id = widget.category['id'];

      // 編集API呼び出し
      final result = await ref.read(updateCategoriesProvider(
        id: id,
        name: name,
        display_order: displayOrder,
      ).future);

      if (result != null && (result['success'] == true || result['status'] == 'success')) {
        if (mounted) {
          Navigator.of(context).pop(true); // trueを返して編集反映
        }
      } else {
        setState(() {
          _errorText = '編集に失敗しました: ${result?['message'] ?? '不明なエラー'}';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = '編集処理中にエラー: $e';
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
        title: const Text('カテゴリー編集'),
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
                              : const Icon(Icons.save),
                          label: Text(_isSubmitting ? '編集中...' : '編集を保存'),
                          onPressed: _isSubmitting ? null : _submitEdit,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: const Text('キャンセル'),
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