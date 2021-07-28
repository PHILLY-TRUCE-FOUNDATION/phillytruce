import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/back_up_mediator_list.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/mediator/add_mediator.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class BackUpMediatorsClient {
  http.Client httpClient = http.Client();

  Future getBackUpMediatorsDetails(int requestBackupId) async {
    Data userData = await SaveDataLocal.getUserDataFromLocal();

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token;

    final Map<String, String> bodyParameter = new Map<String, String>();
    bodyParameter['help_id'] = requestBackupId.toString();

    final url = '${AddMediatorApiClient.baseUrl}/get_mediator_list';
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
          // Utils.dismissProgressBar(context);
          return null;
        },
      );
      responseJson = _response(response);
    } on SocketException {
      Fluttertoast.showToast(
          msg:
              'Some thing went Wrong to get backUp mediator list Please try again later');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return BackUpMediatorList.fromJson(json.decode(response.body));
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
