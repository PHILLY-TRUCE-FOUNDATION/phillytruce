// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mediator_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediatorStatus _$MediatorStatusFromJson(Map<String, dynamic> json) {
  return MediatorStatus(
    data: json['data'] == null
        ? null
        : MediatorStatusData.fromJson(json['data'] as Map<String, dynamic>),
    message: json['message'] as String,
    status: json['status'] as bool,
    statusCode: json['statusCode'] as int,
  );
}

Map<String, dynamic> _$MediatorStatusToJson(MediatorStatus instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'status': instance.status,
      'statusCode': instance.statusCode,
    };

MediatorStatusData _$MediatorStatusDataFromJson(Map<String, dynamic> json) {
  return MediatorStatusData(
    created_at: json['created_at'] as String,
    follow_up_status: json['follow_up_status'] as String,
    help_id: json['help_id'] as int,
    mediator_id: json['mediator_id'] as int,
    user_id: json['user_id'] as int,
    name: json['name'] as String,
    profile_pic: json['profile_pic'] as String,
    device_type: json['device_type'] as String,
    device_token: json['device_token'] as String,
  );
}

Map<String, dynamic> _$MediatorStatusDataToJson(MediatorStatusData instance) =>
    <String, dynamic>{
      'created_at': instance.created_at,
      'follow_up_status': instance.follow_up_status,
      'help_id': instance.help_id,
      'mediator_id': instance.mediator_id,
      'user_id': instance.user_id,
      'name': instance.name,
      'profile_pic': instance.profile_pic,
      'device_type': instance.device_type,
      'device_token': instance.device_token,
    };
