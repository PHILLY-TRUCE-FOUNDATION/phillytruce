import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'add_mediator.dart';

class MediatorLogInClient {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  http.Client httpClient = http.Client();

  Future<UserInformationModel> mediatorLogIn(
      String userType, String email, String password, String deviceType,String deviceToken ,String voIPToken,context) async {
    final Map<String, String> bodyParameter = new Map<String, String>();
    bodyParameter['user_type'] = userType.toString();
    bodyParameter['email'] = email.toString();
    bodyParameter['password'] = password.toString();
    bodyParameter['device_type'] = deviceType.toString();
    bodyParameter['device_token'] = deviceToken.toString();
    bodyParameter['voip_token'] = voIPToken.toString();

    final url = '$_baseUrl/mediator_login';
    var responseJson;
    try {
      Utils.showProgressBar(context);

      final response = await httpClient.post(url, body: bodyParameter).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          print('Flutter Fully Truce' + 'time out');
          Fluttertoast.showToast(
              msg: 'Something went wrong. please try again');
          return null;
        },
      );
      responseJson = _response(response);
    } on SocketException {
      Utils.dismissProgressBar(context);
/*
      Fluttertoast.showToast(
          msg:
              'PLease check your internet connection');*/
      // throw FetchDataException('No Internet connection');
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

dynamic _response(http.Response response) {
  switch (response.statusCode) {
    case 200:
      UserInformationModel model =
          UserInformationModel.fromJson(json.decode(response.body));
      return model;
      break;
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
