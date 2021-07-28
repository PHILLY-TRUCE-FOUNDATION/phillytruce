import 'package:json_annotation/json_annotation.dart';


part 'get_locations.g.dart';
@JsonSerializable()
class GetLocations {
    List<LocationData> data;
    String message;
    bool status;
    int statusCode;

    GetLocations({this.data, this.message, this.status, this.statusCode});

    factory GetLocations.fromJson(Map<String, dynamic> json) => _$GetLocationsFromJson(json);

    Map<String, dynamic> toJson() => _$GetLocationsToJson(this);
}


@JsonSerializable()
class LocationData {
    int help_id;
    int user_id;
    String user_latitude;
    String user_longitude;
    String user_role;

    LocationData({this.help_id, this.user_id, this.user_latitude, this.user_longitude, this.user_role});

    factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);

    Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}