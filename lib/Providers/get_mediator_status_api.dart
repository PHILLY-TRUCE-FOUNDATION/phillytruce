import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/mediator_status.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'mediator/add_mediator.dart';

class GetMediatorStatusClient {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  http.Client httpClient = http.Client();

  Future<MediatorStatus> getMediatorStatus() async {
    Data userData = await SaveDataLocal.getUserDataFromLocal();

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token.toString();

    final Map<String, String> bodyParameter = new Map<String, String>();
    bodyParameter['help_id'] = userData.help_id.toString();

    print('Flutter Fully Truce' +
        userData.help_id.toString() +
        '/' +
        userData.user_id.toString() +
        '/' +
        userData.unique_token.toString());
    final url = '$_baseUrl/get_assign_mediator_to_help';

    var responseJson;
    try {
      final response = await this
          .httpClient
          .post(url, body: bodyParameter, headers: data)
          .timeout(
        const Duration(minutes: 1),
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
              'Some thing went Wrong . to get mediator status Please Try again later');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
    /* if (response.statusCode == 200) {
        return MediatorStatus.fromJson(json.decode(response.body));
      } else {
        Fluttertoast.showToast(msg: 'Something went wrong');
        return MediatorStatus.fromJson(json.decode(response.body));
      }*/
  }
}

dynamic _response(http.Response response) {
  switch (response.statusCode) {
    case 200:
      return MediatorStatus.fromJson(json.decode(response.body));
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
