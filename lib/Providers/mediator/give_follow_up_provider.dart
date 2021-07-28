import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'add_mediator.dart';

class GiveFollowUpToUserClient {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  http.Client httpClient = http.Client();

  Future<bool> giveUserFollowUp(int helpId, String followUp) async {
    Data userData = await SaveDataLocal.getUserDataFromLocal();

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token;

    final Map<String, String> bodyParameter = new Map<String, String>();
    bodyParameter['help_id'] = helpId.toString();
    bodyParameter['follow_up_text'] = followUp.toString();

    final url = '$_baseUrl/give_follow_up';
    var responseJson;
    try {
      final response =
      await httpClient.post(url, body: bodyParameter, headers: data).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          print('Flutter Fully Truce' + 'time out');
          Fluttertoast.showToast(msg: 'Something went wrong . please try again');
          return null;
        },
      );
      responseJson = _response(response);
    } on SocketException {
      Fluttertoast.showToast(
          msg:
          'Some thing went Wrong . to give follow up Please Try again later');
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
dynamic _response(http.Response response) {
  switch (response.statusCode) {
    case 200:
      if (json.decode(response.body)['statusCode'] == 3)
        return true;
      else {
        return false;
      }
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
