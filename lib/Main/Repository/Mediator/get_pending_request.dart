import 'package:flutter_app/Providers/mediator/get_user_pending_requests.dart';

class GetPendingRequestsRepository {
  GetPendingRequestsClient getPendingRequestsClient =
      GetPendingRequestsClient();

  Future getPendingRequestDetails() =>
      getPendingRequestsClient.getPendingRequestDetails();
}
