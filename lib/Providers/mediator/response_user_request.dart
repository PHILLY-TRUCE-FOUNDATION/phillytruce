import 'dart:convert';
import 'dart:io';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'add_mediator.dart';

class ResponseUserRequestClient {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  http.Client httpClient = http.Client();

  Future<String> responseUserRequest(
      int helpId, userId, uniqueToken, context) async {
    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userId.toString();
    data['Token'] = uniqueToken;

    final Map<String, String> bodyParameter = new Map<String, String>();
    bodyParameter['help_id'] = helpId.toString();

    final url = '$_baseUrl/Response_to_user_request';
    var responseJson;
    try {
      final response = await httpClient
          .post(url, body: bodyParameter, headers: data)
          .timeout(
        Duration(minutes: 1),
        onTimeout: () {
          Utils.dismissIOS();
          Utils.dismissProgressBar(context);
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
              'Some thing went Wrong . to response user request Please Try again later');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
    /*if (response.statusCode == 200) {
      print('Flutter Fully Truce' + json.decode(response.body)['message']);
      if (json.decode(response.body)['statusCode'] == 3)
        return json.decode(response.body)['message'].toString();
      else
        return json.decode(response.body)['message'].toString();
      // return UserInformationModel.fromJson(json.decode(response.body)).data;
    } else {
      return json.decode(response.body)['message'].toString();

      // Fluttertoast.showToast(msg: 'Something went wrong');
    }*/
  }
}

dynamic _response(http.Response response) {
  switch (response.statusCode) {
    case 200:
      return json.decode(response.body)['message'].toString();
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
