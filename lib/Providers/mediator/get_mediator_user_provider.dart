import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'add_mediator.dart';

class GetMediatorUserClient {
  http.Client httpClient = http.Client();

  Future getMediatorUserDetails() async {
    Data userData = await SaveDataLocal.getUserDataFromLocal();

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token;

    final url = '${AddMediatorApiClient.baseUrl}/get_Midiator_details';

    var responseJson;
    try {
      final response = await httpClient.get(url, headers: data);
      responseJson = _response(response);
    } on SocketException {
      Fluttertoast.showToast(
          msg: 'Some thing went Wrong to get your data PLease Try again later');
      throw FetchDataException('No Internet connection');

    }
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
