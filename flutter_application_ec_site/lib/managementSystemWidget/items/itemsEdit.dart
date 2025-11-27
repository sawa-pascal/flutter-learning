import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';

class ItemsEditPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;

  const ItemsEditPage({Key? key, required this.item}) : super(key: key);

  @override
  ConsumerState<ItemsEditPage> createState() => _ItemsEditPageState();
}

class _ItemsEditPageState extends ConsumerState<ItemsEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryIdController;

  bool _isSubmitting = false;
  String? _errorText;
  String? _successText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item['name']?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.item['price']?.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.item['quantity']?.toString() ?? '',
    );
    _categoryIdController = TextEditingController(
      text: widget.item['category_id']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryIdController.dispose();
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
      final result = await ref.read(
        updateItemsProvider(
          id: widget.item['id'],
          name: _nameController.text.trim(),
          price: int.tryParse(_priceController.text.trim())!,
          stock: int.tryParse(_stockController.text.trim())!,
          category_id: int.tryParse(_categoryIdController.text.trim())!,
          description: '',
          image: '',
        ).future,
      );

      if (result != null &&
          (result['success'] == true || result['status'] == 'success')) {
        setState(() {
          _successText = '商品情報を更新しました。';
        });
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 400));
          Navigator.of(context).pop(true); // pop してtrueを返す
        }
      } else {
        setState(() {
          _errorText = result?['message'] ?? '更新に失敗しました。';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = '更新時にエラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商品編集')),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              margin: const EdgeInsets.all(28),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '商品情報を編集',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _field(
                        controller: _nameController,
                        label: '商品名',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return '商品名を入力してください';
                          }
                          return null;
                        },
                      ),
                      _field(
                        controller: _categoryIdController,
                        label: 'カテゴリー',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'カテゴリーを入力してください';
                          final n = int.tryParse(val);
                          if (n == null || n < 0) return '正しいカテゴリーを入力してください';
                          return null;
                        },
                      ),
                      _field(
                        controller: _priceController,
                        label: '価格（円）',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty) return '価格を入力してください';
                          final n = int.tryParse(val);
                          if (n == null || n < 0) return '正しい価格を入力してください';
                          return null;
                        },
                      ),
                      _field(
                        controller: _stockController,
                        label: '在庫数',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty) return '在庫数を入力してください';
                          final n = int.tryParse(val);
                          if (n == null || n < 0) return '正しい在庫数を入力してください';
                          return null;
                        },
                      ),

                      if (_errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      if (_successText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _successText!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(_isSubmitting ? '保存中...' : '保存'),
                        onPressed: _isSubmitting ? null : _submitEdit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          textStyle: const TextStyle(fontSize: 17),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('戻る'),
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
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
