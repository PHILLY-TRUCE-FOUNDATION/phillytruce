import 'package:json_annotation/json_annotation.dart';

part 'back_up_mediator_list.g.dart';

@JsonSerializable()
class BackUpMediatorList {
  List<BackUpMediatorListData> data;
  String message;
  bool status;
  int statusCode;

  BackUpMediatorList({this.data, this.message, this.status, this.statusCode});

  factory BackUpMediatorList.fromJson(Map<String, dynamic> json) =>
      _$BackUpMediatorListFromJson(json);

  Map<String, dynamic> toJson() => _$BackUpMediatorListToJson(this);
}

@JsonSerializable()
class BackUpMediatorListData {
  String email;
  String name;
  String phone_no;
  String profile_pic;
  int user_id;

  BackUpMediatorListData(
      {this.email, this.name, this.phone_no, this.profile_pic, this.user_id});

  factory BackUpMediatorListData.fromJson(Map<String, dynamic> json) =>
      _$BackUpMediatorListDataFromJson(json);

  Map<String, dynamic> toJson() => _$BackUpMediatorListDataToJson(this);
}
