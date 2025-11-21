import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/legacy.dart';

part 'cartItemModel.freezed.dart';
part 'cartItemModel.g.dart';

@freezed
sealed class CartItemModel with _$CartItemModel {
  const CartItemModel._();

  const factory CartItemModel({
    required int id,
    required String name,
    required int price,
    required int stock,
    required int quantity,
    required String image_url,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => _$CartItemModelFromJson(json);
}

// セッションのカート変わりここにカートの商品情報を追加していく
final cartItemsProvider = StateProvider<List<CartItemModel>>((ref) => []);
