import 'package:json_annotation/json_annotation.dart';

part 'lat_long_model.g.dart';

@JsonSerializable()
class LatLongModel {
  String latitude, longitude, address, helpId;

  LatLongModel(this.latitude, this.longitude, this.address, this.helpId);

  factory LatLongModel.fromJson(Map<String, dynamic> json) =>
      _$LatLongModelFromJson(json);

  Map<String, dynamic> toJson() => _$LatLongModelToJson(this);
}
