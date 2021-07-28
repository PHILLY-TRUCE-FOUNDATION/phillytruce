import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/mediator/get_user_details.dart';

class UserInformationRepository {
  GetUserDetailsClient getUserDetailsClient = GetUserDetailsClient();

  Future<UserInformationModel> getUserDetails(int helpId) async {
    return await getUserDetailsClient.getUserDetails(helpId);
  }
}
