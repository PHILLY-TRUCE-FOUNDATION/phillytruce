import 'package:flutter_app/Providers/mediator/get_mediator_user_provider.dart';

class GetMediatorUserRepository {
  GetMediatorUserClient getMediatorUserClient = GetMediatorUserClient();

  Future getMediatorUserDetails() =>
      getMediatorUserClient.getMediatorUserDetails();
}
