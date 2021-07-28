import 'package:json_annotation/json_annotation.dart';

part 'mediator_status.g.dart';

@JsonSerializable()
class MediatorStatus {
  MediatorStatusData data;
  String message;
  bool status;
  int statusCode;

  MediatorStatus({this.data, this.message, this.status, this.statusCode});

  factory MediatorStatus.fromJson(Map<String, dynamic> json) =>
      _$MediatorStatusFromJson(json);

  Map<String, dynamic> toJson() => _$MediatorStatusToJson(this);
}

@JsonSerializable()
class MediatorStatusData {
  String created_at;
  String follow_up_status;
  int help_id;
  int mediator_id;
  int user_id;
  String name;
  String profile_pic;
  String device_type;
  String device_token;

  MediatorStatusData(
      {this.created_at,
      this.follow_up_status,
      this.help_id,
      this.mediator_id,
      this.user_id,
      this.name,
      this.profile_pic,
      this.device_type,
      this.device_token});

  factory MediatorStatusData.fromJson(Map<String, dynamic> json) =>
      _$MediatorStatusDataFromJson(json);

  Map<String, dynamic> toJson() => _$MediatorStatusDataToJson(this);
}
