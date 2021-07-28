import 'package:json_annotation/json_annotation.dart';

part 'chatModel.g.dart';

class ChatModel {
  List<ChatData> data;
  String message;
  bool status;
  int statusCode;

  ChatModel({this.data, this.message, this.status, this.statusCode});

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}

class ChatData {
  String chat_notification_status;
  String created_at;
  String device_token;
  String device_type;
  String email;
  String location_name;
  String name;
  String phone_no;
  String profile_pic;
  String unique_token;
  String user_detail;
  int user_id;
  String user_latitude;
  String user_longitude;
  int user_noti_badge;
  String user_option;
  String user_type;
  String voip_token;

  ChatData(
      {this.chat_notification_status,
      this.created_at,
      this.device_token,
      this.device_type,
      this.email,
      this.location_name,
      this.name,
      this.phone_no,
      this.profile_pic,
      this.unique_token,
      this.user_detail,
      this.user_id,
      this.user_latitude,
      this.user_longitude,
      this.user_noti_badge,
      this.user_option,
      this.user_type,
      this.voip_token});

  factory ChatData.fromJson(Map<String, dynamic> json) =>
      _$ChatDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatDataToJson(this);
}
