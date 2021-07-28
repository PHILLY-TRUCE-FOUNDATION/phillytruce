// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lat_long_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLongModel _$LatLongModelFromJson(Map<String, dynamic> json) {
  return LatLongModel(
    json['latitude'] as String,
    json['longitude'] as String,
    json['address'] as String,
    json['helpId'] as String,
  );
}

Map<String, dynamic> _$LatLongModelToJson(LatLongModel instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'helpId': instance.helpId,
    };
