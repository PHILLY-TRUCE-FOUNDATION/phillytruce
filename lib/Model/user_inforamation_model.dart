import 'package:json_annotation/json_annotation.dart';

part 'user_inforamation_model.g.dart';

@JsonSerializable()
class UserInformationModel {
  Data data;
  String message;
  bool status;
  int statusCode;

  UserInformationModel({this.data, this.message, this.status, this.statusCode});

  factory UserInformationModel.fromJson(Map<String, dynamic> json) =>
      _$UserInformationModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserInformationModelToJson(this);
}

@JsonSerializable()
class Data {
  String device_token;
  String device_type;
  String email;
  String location_name;
  String name;
  String phone_no;
  String user_detail;
  String user_latitude;
  String user_longitude;
  String user_option;
  String user_type;
  int user_id;
  String unique_token;
  String profile_pic;
  String is_approve_mediator;
  int help_id;
  String help_status;
  String voip_token;

  Data(
      this.device_token,
      this.device_type,
      this.email,
      this.location_name,
      this.name,
      this.phone_no,
      this.user_detail,
      this.user_latitude,
      this.user_longitude,
      this.user_option,
      this.user_type,
      this.user_id,
      this.unique_token,
      this.help_id,
      this.is_approve_mediator,
      this.help_status,
      this.voip_token);

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
