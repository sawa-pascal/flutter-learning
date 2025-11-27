import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../myApiProvider.dart';

class ItemsCreatorPage extends ConsumerStatefulWidget {
  const ItemsCreatorPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ItemsCreatorPage> createState() => _ItemsCreatorPageState();
}

class _ItemsCreatorPageStateFields {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController descriptionController;
  late TextEditingController imageController;
  int? selectedCategoryId;
  String? selectedCategoryName;

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
  final _fields = _ItemsCreatorPageStateFields();
  bool _isSubmitting = false;
  String? _errorText;
  String? _successText;
  List<dynamic> _categories = [];
  bool _categoriesLoading = true;

  File? _pickedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

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
            _fields.selectedCategoryName =
                _categories.first['name']?.toString() ?? '';
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  // --- use uploadItemImageProvider（Riverpod経由） to upload the image file, set _uploadedImageUrl and update URL field ---
  Future<void> _uploadImage() async {
    if (_pickedImage == null) {
      setState(() {
        _errorText = "画像ファイルが選択されていません";
      });
      return;
    }
    setState(() {
      _isUploadingImage = true;
      _errorText = null;
    });
    try {
      final imageBytes = await _pickedImage!.readAsBytes();
      final categoryName = _fields.selectedCategoryName ?? '';
      final res = await ref.read(
        uploadItemImageProvider(
          categoryName: categoryName,
          imageBytes: imageBytes,
        ).future,
      );
      print(res);
      // print(res); // For debugging: print response to console
      if (res != null &&
          res is Map &&
          res['image_url'] is String &&
          res['image_url'].toString().isNotEmpty) {
        setState(() {
          _uploadedImageUrl = res['image_url'] as String;
          _fields.imageController.text = _uploadedImageUrl!;
        });
      } else {
        setState(() {
          _errorText = "画像のアップロードに失敗しました";
        });
      }
    } catch (e) {
      setState(() {
        _errorText = "画像のアップロードエラー: $e";
      });
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }
  // --- end of uploadItemImageProvider section ---

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
      final description = _fields.descriptionController.text.trim();
      final image = _uploadedImageUrl ?? _fields.imageController.text.trim();
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
          image_url: image,
        ).future,
      );

      if (result != null &&
          (result['success'] == true || result['status'] == 'success')) {
        setState(() {
          _successText = '商品を登録しました！';
        });
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pop(true);
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

  Widget _imageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "画像アップロード（任意）",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isUploadingImage ? null : _pickImage,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          icon: const Icon(Icons.image),
          label: Text(_isUploadingImage ? "アップロード中..." : "画像を選択"),
        ),

        const SizedBox(height: 10),
        if (_pickedImage != null)
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(_pickedImage!, height: 120),
                if (_isUploadingImage)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                if (!_isUploadingImage)
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.red,
                    tooltip: "画像を削除",
                    onPressed: () {
                      setState(() {
                        _pickedImage = null;
                        _uploadedImageUrl = null;
                        _fields.imageController.clear();
                      });
                    },
                  ),
              ],
            ),
          ),
        if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '画像アップロード済み',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
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
                                    final selected = _categories.firstWhere(
                                      (c) =>
                                          (c['id'] is int
                                              ? c['id']
                                              : int.tryParse(
                                                  c['id'].toString(),
                                                )) ==
                                          val,
                                      orElse: () => {},
                                    );
                                    _fields.selectedCategoryName =
                                        selected['name']?.toString() ?? '';
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
                            final int? p = int.tryParse(val.trim());
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
                            final int? s = int.tryParse(val.trim());
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
                        _imageUploadSection(),
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
