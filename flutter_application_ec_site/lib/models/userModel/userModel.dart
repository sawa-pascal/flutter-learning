import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/legacy.dart';

part 'userModel.freezed.dart';
part 'userModel.g.dart';

@freezed
sealed class UserModel with _$UserModel {
  const UserModel._(); // Added private constructor for custom getters/methods if required

  const factory UserModel({
    required int id,
    required String name,
    required String email,
    required String tel,
    required String password,
    required int prefecture_id,
    String? address,
    // 必要があれば他のフィールドも追加
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

final userModelProvider = StateProvider<UserModel?>((ref) => null); 
