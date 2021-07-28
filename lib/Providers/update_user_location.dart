import 'dart:io';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'mediator/add_mediator.dart';

class UpdateUserLocationClient {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  final http.Client httpClient;

  Data userData;

  UpdateUserLocationClient({
    @required this.httpClient,
  }) : assert(httpClient != null);

  Future<http.Response> updateUserLocation(
      LatLng userLatLong, helpId, locationName) async {
    userData = await SaveDataLocal.getUserDataFromLocal();

    final url = '$_baseUrl/user_update_location';
    print('url ' + url);

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token;

    final Map<String, String> latLong = new Map<String, String>();
    latLong['user_latitude'] = userLatLong.latitude.toString();
    latLong['user_longitude'] = userLatLong.longitude.toString();
    latLong['location_name'] = locationName.trim().toString();
    latLong['help_id'] = helpId.toString();

    var responseJson;
    try {
      final response =
          await this.httpClient.post(url, body: latLong, headers: data).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          print('Flutter Fully Truce' + 'time out');
          Fluttertoast.showToast(
              msg: 'Something went wrong . please try again');
          return null;
        },
      );
      responseJson = _response(response);
    } on SocketException {
      Fluttertoast.showToast(
          msg:
              'Some thing went Wrong . to update location Please Try again later');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
    /* if (response.statusCode == 200) {
      return response;
    } else {
      print('Fully Truce Location ' + response.body.toString());
      Fluttertoast.showToast(msg: 'Location Something went wrong');
      return null;
    }*/
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return response;
      case 400:
      case 401:

      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode :${response.statusCode}');
    }
  }
}
