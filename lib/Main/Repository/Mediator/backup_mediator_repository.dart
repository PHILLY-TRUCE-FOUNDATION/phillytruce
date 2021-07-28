import 'package:flutter_app/Providers/mediator/get_back_up_mediator.dart';

class GetBackUpMediatorRepository {
  BackUpMediatorsClient getBackUpMediatorClient = BackUpMediatorsClient();

  Future getBackUpMediatorDetails(int requestBackupId) =>
      getBackUpMediatorClient.getBackUpMediatorsDetails(requestBackupId);
}
