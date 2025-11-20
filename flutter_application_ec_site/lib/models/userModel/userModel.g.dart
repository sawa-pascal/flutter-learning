// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  tel: json['tel'] as String,
  hashed_password: json['hashed_password'] as String,
  prefecture_id: (json['prefecture_id'] as num).toInt(),
  address: json['address'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'tel': instance.tel,
      'hashed_password': instance.hashed_password,
      'prefecture_id': instance.prefecture_id,
      'address': instance.address,
    };
