import 'package:json_annotation/json_annotation.dart';

part 'pendig_requests_model.g.dart';

@JsonSerializable()
class GetPendingRequestsModel {
  List<PendingRequestData> data;
  String message;
  bool status;
  int statusCode;

  GetPendingRequestsModel(
      {this.data, this.message, this.status, this.statusCode});

  factory GetPendingRequestsModel.fromJson(Map<String, dynamic> json) =>
      _$GetPendingRequestsModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetPendingRequestsModelToJson(this);
}

@JsonSerializable()
class PendingRequestData {
  String created_at;
  String email;
  int help_id;
  String location_name;
  String name;
  String phone_no;
  String request_type;
  int user_id;
  String user_latitude;
  String user_longitude;
  int request_backup_id;

  PendingRequestData(
      {this.created_at,
      this.email,
      this.help_id,
      this.location_name,
      this.name,
      this.phone_no,
      this.request_type,
      this.user_id,
      this.user_latitude,
      this.user_longitude,
      this.request_backup_id});

  factory PendingRequestData.fromJson(Map<String, dynamic> json) =>
      _$PendingRequestDataFromJson(json);

  Map<String, dynamic> toJson() => _$PendingRequestDataToJson(this);
}
