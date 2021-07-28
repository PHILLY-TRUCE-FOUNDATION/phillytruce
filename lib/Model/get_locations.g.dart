// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetLocations _$GetLocationsFromJson(Map<String, dynamic> json) {
  return GetLocations(
    data: (json['data'] as List)
        ?.map((e) =>
            e == null ? null : LocationData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    message: json['message'] as String,
    status: json['status'] as bool,
    statusCode: json['statusCode'] as int,
  );
}

Map<String, dynamic> _$GetLocationsToJson(GetLocations instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'status': instance.status,
      'statusCode': instance.statusCode,
    };

LocationData _$LocationDataFromJson(Map<String, dynamic> json) {
  return LocationData(
    help_id: json['help_id'] as int,
    user_id: json['user_id'] as int,
    user_latitude: json['user_latitude'] as String,
    user_longitude: json['user_longitude'] as String,
    user_role: json['user_role'] as String,
  );
}

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'help_id': instance.help_id,
      'user_id': instance.user_id,
      'user_latitude': instance.user_latitude,
      'user_longitude': instance.user_longitude,
      'user_role': instance.user_role,
    };
