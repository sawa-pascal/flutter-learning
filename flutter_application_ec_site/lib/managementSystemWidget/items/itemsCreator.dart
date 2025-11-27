import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';

class ItemsCreatorPage extends ConsumerStatefulWidget {
  const ItemsCreatorPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ItemsCreatorPage> createState() => _ItemsCreatorPageState();
}

class _ItemsCreatorStateFields {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController descriptionController; // 説明文追加
  late TextEditingController imageController; // 画像URL追加
  int? selectedCategoryId;

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    imageController.dispose();
  }
}

class _ItemsCreatorPageState extends ConsumerState<ItemsCreatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _fields = _ItemsCreatorStateFields();
  bool _isSubmitting = false;
  String? _errorText;
  String? _successText;
  List<dynamic> _categories = [];
  bool _categoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _fields.nameController = TextEditingController();
    _fields.priceController = TextEditingController();
    _fields.stockController = TextEditingController();
    _fields.descriptionController = TextEditingController();
    _fields.imageController = TextEditingController();
    _fetchCategories();
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _categoriesLoading = true;
    });
    try {
      final catResult = await ref.read(categoriesProvider.future);
      if (catResult != null && catResult is List) {
        setState(() {
          _categories = catResult;
          if (_categories.isNotEmpty) {
            _fields.selectedCategoryId = (_categories.first['id'] is int)
                ? _categories.first['id']
                : int.tryParse(_categories.first['id'].toString());
          }
        });
      } else {
        setState(() {
          _errorText = 'カテゴリーの取得に失敗しました';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'カテゴリー取得エラー: $e';
      });
    } finally {
      setState(() {
        _categoriesLoading = false;
      });
    }
  }

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fields.selectedCategoryId == null) {
      setState(() {
        _errorText = 'カテゴリーを選択してください';
      });
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
      _successText = null;
    });
    try {
      final name = _fields.nameController.text.trim();
      final price = int.tryParse(_fields.priceController.text.trim());
      final stock = int.tryParse(_fields.stockController.text.trim());
      final catId = _fields.selectedCategoryId;
      final description = _fields.descriptionController.text.trim(); // 追加
      final image = _fields.imageController.text.trim(); // 追加
      if (price == null || price < 0) {
        setState(() {
          _errorText = '価格は0以上の整数で入力してください';
        });
        return;
      }
      if (stock == null || stock < 0) {
        setState(() {
          _errorText = '在庫は0以上の整数で入力してください';
        });
        return;
      }
      final result = await ref.read(
        createItemsProvider(
          name: name,
          category_id: catId!,
          price: price,
          stock: stock,
          description: description,
          image: image,
        ).future,
      );

      if (result != null &&
          (result['success'] == true || result['status'] == 'success')) {
        setState(() {
          _successText = '商品を登録しました！';
        });
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pop(true); // 戻ってリスト側でref.invalidateする想定
        }
      } else {
        setState(() {
          _errorText = '登録失敗: ${result?['message'] ?? '不明なエラー'}';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = '登録エラー: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商品登録'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                margin: const EdgeInsets.all(24.0),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '商品登録フォーム',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fields.nameController,
                          decoration: const InputDecoration(
                            labelText: '商品名 *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                                  ? '商品名を入力してください'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _categoriesLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : DropdownButtonFormField<int>(
                                value: _fields.selectedCategoryId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'カテゴリー *',
                                  border: OutlineInputBorder(),
                                ),
                                items: _categories.map<DropdownMenuItem<int>>((
                                  cat,
                                ) {
                                  return DropdownMenuItem<int>(
                                    value: (cat['id'] is int)
                                        ? cat['id']
                                        : int.tryParse(cat['id'].toString()),
                                    child: Text(cat['name']?.toString() ?? '-'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _fields.selectedCategoryId = val;
                                  });
                                },
                                validator: (val) =>
                                    val == null ? 'カテゴリーを選択してください' : null,
                              ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fields.priceController,
                          decoration: const InputDecoration(
                            labelText: '価格 *',
                            border: OutlineInputBorder(),
                            prefixText: '¥ ',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty)
                              return '価格を入力してください';
                            final num? p = int.tryParse(val.trim());
                            if (p == null || p < 0) return '0以上の整数で入力';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fields.stockController,
                          decoration: const InputDecoration(
                            labelText: '在庫数 *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty)
                              return '在庫を入力してください';
                            final num? s = int.tryParse(val.trim());
                            if (s == null || s < 0) return '0以上の整数で入力';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fields.descriptionController,
                          decoration: const InputDecoration(
                            labelText: '説明文',
                            hintText: '商品の説明を入力してください',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fields.imageController,
                          decoration: const InputDecoration(
                            labelText: '画像URL',
                            hintText: '画像のURLを入力してください（任意）',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 24),
                        if (_errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorText!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_successText != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _successText!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ElevatedButton.icon(
                          icon: _isSubmitting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add),
                          label: Text(_isSubmitting ? '登録中...' : '商品を登録'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green,
                          ),
                          onPressed: _isSubmitting ? null : _submitItem,
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('一覧に戻る'),
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
      ),
    );
  }
}
