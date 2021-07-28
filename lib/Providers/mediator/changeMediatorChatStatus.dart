import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/mediator/add_mediator.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ChangeMediatorChatStatus {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  http.Client httpClient = http.Client();

  Future<bool> changeMediatorChatStatus(String notifyStatus, context) async {
    Data userData = await SaveDataLocal.getUserDataFromLocal();

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token.toString();

    final Map<String, String> bodyParameter = new Map<String, String>();
    bodyParameter['notify_status'] = notifyStatus.toString();

    final url = '$_baseUrl/update_chat_notification_status';
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

  print('fneowif' + response.body.toString());

  switch (response.statusCode) {
    case 200:
      return json.decode(response.body)['status'];
    case 400:
      return false;
    case 401:
      return false;

    case 403:
      return false;

      throw UnauthorisedException(response.body.toString());
    case 500:
      return false;

    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode :${response.statusCode}');
  }
}
