import 'dart:convert';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveDataLocal {
  static SharedPreferences prefs;
  static List data = [];
  static String userDataName = 'UserData';

  // static String mediatorDataName = 'MediatorData';
  static String userHelpStatus = 'HelpStatus';
  static String respondStatus = 'RespondStatus';

  static String mediatorType = 'MediatorType';
  static String callNotification = 'CallNotification';

  static saveUserData(UserInformationModel userData) async {
    prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(userData.data);
    await prefs.setString(userDataName, json);
  }

  static Future getUserDataFromLocal() async {
    prefs = await SharedPreferences.getInstance();

    String userString = prefs.getString(userDataName);
    if (userString != null) {
      Map userMap = jsonDecode(userString);
      Data user = Data.fromJson(userMap);
      return user;
    }
    else{
      return false;
    }
  }

  /* static saveMediatorLogInData(UserInformationModel userData) async {
    prefs = await SharedPreferences.getInstance();
    prefs.clear();
    String json = jsonEncode(userData.data);
    await prefs.setString(mediatorDataName, json);
  }
*/
  static saveUserStatus(String status) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(userHelpStatus, status);
  }

  static getUserStatus() async {
    prefs = prefs = await SharedPreferences.getInstance();
    String status = prefs.getString(userHelpStatus);
    if (status != null) {
      return status;
    } else {
      return null;
    }
  }

  static saveRespondStatus(bool isRespond) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setBool(respondStatus, isRespond);
  }

  static getRespondStatus() async {
    prefs = await SharedPreferences.getInstance();
    bool isResponded = prefs.getBool(respondStatus);
    print('isRequested' + isResponded.toString());
    if (isResponded != null) {
      return isResponded;
    } else {
      return false;
    }
  }

  static saveCallData(Map<String, dynamic> data) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString(callNotification, json.encode(data));
  }

  static getCallData() async {
    prefs = await SharedPreferences.getInstance();
    String callData = prefs.getString(callNotification);
    if (callData != null) {
      return json.decode(callData);
    } else {
      return false;
    }
  }

  static removeCallData() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('notificationDataStore');
    // prefs.remove(mediatorType);
  }

  static saveRespondedMediatorType(
      bool isBackUpMediator, userId, helpId, requestBackupId) async {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isBackUpMediator'] = isBackUpMediator;
    data['userId'] = userId;
    data['helpId'] = helpId;
    data['request_backup_id'] = requestBackupId;

    prefs = await SharedPreferences.getInstance();

    prefs.setString(mediatorType, json.encode(data));
  }

  static getRespondedMediatorType() async {
    prefs = await SharedPreferences.getInstance();
    String mediator = prefs.getString(mediatorType);
    if (mediator != null) {
      return json.decode(mediator);
    } else {
      return false;
    }
  }

  static removeData() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove(respondStatus);
    prefs.remove(mediatorType);
  }

  static removeUserData() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove(userDataName);
  }

/* static getMediatorDataFromLocal() async {
    prefs = await SharedPreferences.getInstance();

    String userString = prefs.getString(mediatorDataName);
    if (userString != null) {
      Map userMap = jsonDecode(userString);
      Data user = Data.fromJson(userMap);
      return user;
    } else {
      return null;
    }
  }*/

/*static removeUserData() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove(userHelpStatus);
  }

  static removeMediatorData() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove(userHelpStatus);
    await prefs.remove(backUpMediator);
    await prefs.remove(respondStatus);
  }*/

}

class RespondedMediatorClass {
  int userId;
  int helpId;
  bool isBackUpMediator;
}
