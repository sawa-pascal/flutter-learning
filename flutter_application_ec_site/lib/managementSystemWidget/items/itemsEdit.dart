import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../myApiProvider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;

  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  String? _errorText;
  String? _successText;

  File? _pickedImage;
  String? _uploadedImageUrl;

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
    _descriptionController = TextEditingController(
      text: widget.item['description']?.toString() ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.item['image_url']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryIdController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
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
      // カテゴリーIDからカテゴリー名を取得してアップロード時に渡す
      String categoryName = "";
      final categoryId = int.tryParse(_categoryIdController.text.trim());
      if (categoryId != null && mounted) {
        // categoriesProvider は List<Map> を返す想定
        final categories = await ref.read(categoriesProvider.future);
        final category = categories.firstWhere(
          (c) => c['id'].toString() == categoryId.toString(),
          orElse: () => null,
        );
        if (category != null && category['name'] != null) {
          categoryName = category['name'].toString();
        }
      }
      final res = await ref.read(
        uploadItemImageProvider(
          categoryName: categoryName,
          imageBytes: imageBytes,
        ).future,
      );
      if (res != null &&
          res is Map &&
          res['image_url'] is String &&
          res['image_url'].toString().isNotEmpty) {
        setState(() {
          _uploadedImageUrl = res['image_url'] as String;
          _imageUrlController.text = _uploadedImageUrl!;
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
          description: _descriptionController.text.trim(),
          image_url: _uploadedImageUrl ?? _imageUrlController.text.trim(),
          origin_image_url: widget.item['image_url']?.toString() ?? '',
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
    int maxLines = 1,
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
        maxLines: maxLines,
      ),
    );
  }

  Widget _imageUploadSection() {
    final imageUrl = _uploadedImageUrl ?? _imageUrlController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("商品画像", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        ElevatedButton.icon(
          onPressed: _isUploadingImage ? null : _pickImage,
          icon: const Icon(Icons.image),
          label: Text(_isUploadingImage ? "アップ中..." : "選択"),
        ),

        const SizedBox(height: 10),
        if (_pickedImage != null) ...{
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                _pickedImage!,
                height: 98,
                width: 98,
                fit: BoxFit.contain,
              ),
            ),
          ),
        } else if (imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              imageBaseUrl + imageUrl,
              height: 98,
              width: 98,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) {
                return Container(
                  height: 98,
                  width: 98,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 36),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商品編集')),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                          if (val == null || val.isEmpty) {
                            return 'カテゴリーを入力してください';
                          }
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
                      _field(
                        controller: _descriptionController,
                        label: '説明（オプション）',
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        validator: (val) {
                          // 説明は必須でない
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      _imageUploadSection(),

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
