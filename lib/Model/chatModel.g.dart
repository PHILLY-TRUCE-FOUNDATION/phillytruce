// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) {
  return ChatModel(
    data: (json['data'] as List)
        ?.map((e) =>
            e == null ? null : ChatData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    message: json['message'] as String,
    status: json['status'] as bool,
    statusCode: json['statusCode'] as int,
  );
}

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'status': instance.status,
      'statusCode': instance.statusCode,
    };

ChatData _$ChatDataFromJson(Map<String, dynamic> json) {
  return ChatData(
    chat_notification_status: json['chat_notification_status'] as String,
    created_at: json['created_at'] as String,
    device_token: json['device_token'] as String,
    device_type: json['device_type'] as String,
    email: json['email'] as String,
    location_name: json['location_name'] as String,
    name: json['name'] as String,
    phone_no: json['phone_no'] as String,
    profile_pic: json['profile_pic'] as String,
    unique_token: json['unique_token'] as String,
    user_detail: json['user_detail'] as String,
    user_id: json['user_id'] as int,
    user_latitude: json['user_latitude'] as String,
    user_longitude: json['user_longitude'] as String,
    user_noti_badge: json['user_noti_badge'] as int,
    user_option: json['user_option'] as String,
    user_type: json['user_type'] as String,
    voip_token: json['voip_token'] as String,
  );
}

Map<String, dynamic> _$ChatDataToJson(ChatData instance) => <String, dynamic>{
      'chat_notification_status': instance.chat_notification_status,
      'created_at': instance.created_at,
      'device_token': instance.device_token,
      'device_type': instance.device_type,
      'email': instance.email,
      'location_name': instance.location_name,
      'name': instance.name,
      'phone_no': instance.phone_no,
      'profile_pic': instance.profile_pic,
      'unique_token': instance.unique_token,
      'user_detail': instance.user_detail,
      'user_id': instance.user_id,
      'user_latitude': instance.user_latitude,
      'user_longitude': instance.user_longitude,
      'user_noti_badge': instance.user_noti_badge,
      'user_option': instance.user_option,
      'user_type': instance.user_type,
      'voip_token': instance.voip_token,
    };
