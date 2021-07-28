import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'add_mediator.dart';

class GetUserDetailsClient {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  http.Client httpClient = http.Client();

  Future<UserInformationModel> getUserDetails(int helpId) async {
    Data userData = await SaveDataLocal.getUserDataFromLocal();

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token;

    final Map<String, String> bodyParameter = new Map<String, String>();
    bodyParameter['help_id'] = helpId.toString();

    final url = '$_baseUrl/get_user_information';
    var responseJson;
    try {
      final response = await httpClient
          .post(url, body: bodyParameter, headers: data)
          .timeout(
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
              'Some thing went Wrong . to get User Information Please Try again later');
      throw FetchDataException('No Internet connection');
    }
    /*if (response.statusCode == 200) {
      UserInformationModel userInformation =
      UserInformationModel.fromJson(json.decode(response.body));
      if (userInformation.status == true && userInformation.statusCode == 3) {
        return UserInformationModel.fromJson(json.decode(response.body));
      } else {
        print('Flutter Philly 2' + userInformation.message.toString());
        return userInformation;
      }
    }
    else {
      Fluttertoast.showToast(msg: 'Something went wrong');
      return null;
    }*/
    return responseJson;
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return UserInformationModel.fromJson(json.decode(response.body));
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
