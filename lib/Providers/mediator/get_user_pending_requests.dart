import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/pendig_requests_model.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/mediator/add_mediator.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class GetPendingRequestsClient {
  http.Client httpClient = http.Client();

  Future getPendingRequestDetails() async {
    Data userData = await SaveDataLocal.getUserDataFromLocal();

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token;

    final url = '${AddMediatorApiClient.baseUrl}/pending_user_help_list';
    var responseJson;
    try {
      final response = await httpClient.get(url, headers: data).timeout(
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
              'Some thing went Wrong . to get pending request Please Try again later');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;

    /* GetPendingRequestsModel requestInformation =
    GetPendingRequestsModel.fromJson(json.decode(response.body));

    if (requestInformation.status == true && requestInformation.statusCode == 3)
      return requestInformation;
    else {
      return requestInformation;
    }*/
  }
}

dynamic _response(http.Response response) {
  switch (response.statusCode) {
    case 200:
      return GetPendingRequestsModel.fromJson(json.decode(response.body));
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
