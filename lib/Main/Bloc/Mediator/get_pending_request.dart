import 'dart:async';

import 'package:flutter_app/Main/Repository/Mediator/get_pending_request.dart';
import 'package:flutter_app/Model/pendig_requests_model.dart';
import 'package:rxdart/rxdart.dart';

class GetPendingRequestBloc {
  final GetPendingRequestsRepository _repository =
      GetPendingRequestsRepository();

  final BehaviorSubject<GetPendingRequestsModel> _subject =
      BehaviorSubject<GetPendingRequestsModel>();

  getRequestDetails() async {
    GetPendingRequestsModel pendingRequestsDetails =
        await _repository.getPendingRequestDetails();
    subject.sink.add(pendingRequestsDetails);
  }

  dispose() {
    _subject.close();
  }

  StreamController<GetPendingRequestsModel> get subject => _subject;
}

final getPendingRequestBloc = GetPendingRequestBloc();
