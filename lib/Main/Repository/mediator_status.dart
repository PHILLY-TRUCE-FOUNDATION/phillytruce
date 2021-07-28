import 'package:flutter_app/Model/mediator_status.dart';
import 'package:flutter_app/Providers/get_mediator_status_api.dart';

class MediatorStatusRepository {
  GetMediatorStatusClient getUserDetailsClient = GetMediatorStatusClient();

  Future<MediatorStatus> getMediatorStatusDetails() =>
      getUserDetailsClient.getMediatorStatus();
}
