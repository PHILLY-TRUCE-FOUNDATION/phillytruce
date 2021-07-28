// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_inforamation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInformationModel _$UserInformationModelFromJson(Map<String, dynamic> json) {
  return UserInformationModel(
    data: json['data'] == null
        ? null
        : Data.fromJson(json['data'] as Map<String, dynamic>),
    message: json['message'] as String,
    status: json['status'] as bool,
    statusCode: json['statusCode'] as int,
  );
}

Map<String, dynamic> _$UserInformationModelToJson(
        UserInformationModel instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'status': instance.status,
      'statusCode': instance.statusCode,
    };

Data _$DataFromJson(Map<String, dynamic> json) {
  return Data(
    json['device_token'] as String,
    json['device_type'] as String,
    json['email'] as String,
    json['location_name'] as String,
    json['name'] as String,
    json['phone_no'] as String,
    json['user_detail'] as String,
    json['user_latitude'] as String,
    json['user_longitude'] as String,
    json['user_option'] as String,
    json['user_type'] as String,
    json['user_id'] as int,
    json['unique_token'] as String,
    json['help_id'] as int,
    json['is_approve_mediator'] as String,
    json['help_status'] as String,
    json['voip_token'] as String,
  )..profile_pic = json['profile_pic'] as String;
}

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'device_token': instance.device_token,
      'device_type': instance.device_type,
      'email': instance.email,
      'location_name': instance.location_name,
      'name': instance.name,
      'phone_no': instance.phone_no,
      'user_detail': instance.user_detail,
      'user_latitude': instance.user_latitude,
      'user_longitude': instance.user_longitude,
      'user_option': instance.user_option,
      'user_type': instance.user_type,
      'user_id': instance.user_id,
      'unique_token': instance.unique_token,
      'profile_pic': instance.profile_pic,
      'is_approve_mediator': instance.is_approve_mediator,
      'help_id': instance.help_id,
      'help_status': instance.help_status,
      'voip_token': instance.voip_token,
    };
