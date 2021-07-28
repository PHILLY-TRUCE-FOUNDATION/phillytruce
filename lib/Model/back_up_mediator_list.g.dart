// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'back_up_mediator_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackUpMediatorList _$BackUpMediatorListFromJson(Map<String, dynamic> json) {
  return BackUpMediatorList(
    data: (json['data'] as List)
        ?.map((e) => e == null
            ? null
            : BackUpMediatorListData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    message: json['message'] as String,
    status: json['status'] as bool,
    statusCode: json['statusCode'] as int,
  );
}

Map<String, dynamic> _$BackUpMediatorListToJson(BackUpMediatorList instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'status': instance.status,
      'statusCode': instance.statusCode,
    };

BackUpMediatorListData _$BackUpMediatorListDataFromJson(
    Map<String, dynamic> json) {
  return BackUpMediatorListData(
    email: json['email'] as String,
    name: json['name'] as String,
    phone_no: json['phone_no'] as String,
    profile_pic: json['profile_pic'] as String,
    user_id: json['user_id'] as int,
  );
}

Map<String, dynamic> _$BackUpMediatorListDataToJson(
        BackUpMediatorListData instance) =>
    <String, dynamic>{
      'email': instance.email,
      'name': instance.name,
      'phone_no': instance.phone_no,
      'profile_pic': instance.profile_pic,
      'user_id': instance.user_id,
    };
