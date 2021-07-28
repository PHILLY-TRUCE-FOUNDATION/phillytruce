import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'add_mediator.dart';

class MediatorForgotPasswordClient {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  http.Client httpClient = http.Client();

  Future<bool> mediatorForgotPassword(String email, context) async {
    final Map<String, String> data = new Map<String, String>();
    data['email'] = email.toString();

    final url = '$_baseUrl/forgot_password';
    var responseJson;
    try {
      final response = await httpClient.post(url, body: data).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          print('Flutter Fully Truce' + 'time out');
          Fluttertoast.showToast(
              msg: 'Something went wrong . please try again');
          return null;
        },
      );
      print('uinuerf' + response.body.toString());
      responseJson = _response(response, context);
    } on SocketException {
      Fluttertoast.showToast(
          msg: 'Some thing went Wrong . Please Try again later');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
    /* print('Flutter Fully Truce' + json.decode(response.body).toString());
      if (json.decode(response.body)['statusCode'] == 3)
        return true;
      else {
        return false;
      }*/
  }
}

dynamic _response(http.Response response, context) {
  print('niofwe' + json.decode(response.body).toString());
  switch (response.statusCode) {
    case 200:
      return json.decode(response.body)['status'];
      break;
    case 400:
    case 401:
      Utils.dismissProgressBar(context);
      break;
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 500:
      Utils.dismissProgressBar(context);
      break;
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode :${response.statusCode}');
  }
}
