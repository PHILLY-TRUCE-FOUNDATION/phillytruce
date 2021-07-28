// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pendig_requests_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPendingRequestsModel _$GetPendingRequestsModelFromJson(
    Map<String, dynamic> json) {
  return GetPendingRequestsModel(
    data: (json['data'] as List)
        ?.map((e) => e == null
            ? null
            : PendingRequestData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    message: json['message'] as String,
    status: json['status'] as bool,
    statusCode: json['statusCode'] as int,
  );
}

Map<String, dynamic> _$GetPendingRequestsModelToJson(
        GetPendingRequestsModel instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'status': instance.status,
      'statusCode': instance.statusCode,
    };

PendingRequestData _$PendingRequestDataFromJson(Map<String, dynamic> json) {
  return PendingRequestData(
    created_at: json['created_at'] as String,
    email: json['email'] as String,
    help_id: json['help_id'] as int,
    location_name: json['location_name'] as String,
    name: json['name'] as String,
    phone_no: json['phone_no'] as String,
    request_type: json['request_type'] as String,
    user_id: json['user_id'] as int,
    user_latitude: json['user_latitude'] as String,
    user_longitude: json['user_longitude'] as String,
    request_backup_id: json['request_backup_id'] as int,
  );
}

Map<String, dynamic> _$PendingRequestDataToJson(PendingRequestData instance) =>
    <String, dynamic>{
      'created_at': instance.created_at,
      'email': instance.email,
      'help_id': instance.help_id,
      'location_name': instance.location_name,
      'name': instance.name,
      'phone_no': instance.phone_no,
      'request_type': instance.request_type,
      'user_id': instance.user_id,
      'user_latitude': instance.user_latitude,
      'user_longitude': instance.user_longitude,
      'request_backup_id': instance.request_backup_id,
    };
