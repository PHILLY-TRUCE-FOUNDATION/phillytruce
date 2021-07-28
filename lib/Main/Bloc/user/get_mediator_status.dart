import 'dart:async';

import 'package:flutter_app/Main/Repository/mediator_status.dart';
import 'package:flutter_app/Model/mediator_status.dart';
import 'package:rxdart/rxdart.dart';

class GetMediatorStatusBloc {
  final MediatorStatusRepository _repository = MediatorStatusRepository();

  final BehaviorSubject<MediatorStatus> _subject =
      BehaviorSubject<MediatorStatus>();

  Stream<MediatorStatus> get getMediatorStatusStream => _subject.stream;

  getMediatorStatus() async {
    print('on BehaviorSubject ' + 'fwef');
    MediatorStatus mediatorStatus =
        await _repository.getMediatorStatusDetails();
    subject.sink.add(mediatorStatus);
  }

  dispose() {
    _subject.close();
  }

  StreamController<MediatorStatus> get subject => _subject;
}

final getMediatorStatusBloc = GetMediatorStatusBloc();
