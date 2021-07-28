import 'dart:async';
import 'dart:io';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'mediator/add_mediator.dart';

class CallApiClient {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  http.Client httpClient = http.Client();

  Future<http.Response> callUser(informationModel, context) async {
    final url = '$_baseUrl/send_phone_call_notification';
    Data userData = await SaveDataLocal.getUserDataFromLocal();

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token.toString();

    print('Header DAta' + data.toString());
    var responseJson;
    try {
      final response = await this
          .httpClient
          .post(url, body: informationModel, headers: data)
          .timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          print('Flutter Fully Truce' + 'time out');
          Fluttertoast.showToast(
              msg: 'Something went wrong . please try again');
          Utils.dismissProgressBar(context);
          return null;
        },
      );
      responseJson = _response(response);
    } on SocketException {
      Fluttertoast.showToast(
          msg:
              'Some thing went Wrong . to get User Information Please Try again later');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }
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
