import 'dart:async';

import 'package:flutter_app/Main/Repository/Mediator/backup_mediator_repository.dart';
import 'package:flutter_app/Model/back_up_mediator_list.dart';

class GetBackUpMediatorBloc {
  final GetBackUpMediatorRepository _repository = GetBackUpMediatorRepository();

  final StreamController<BackUpMediatorList> _subject =
      StreamController<BackUpMediatorList>.broadcast();

  Stream<BackUpMediatorList> get getMediatorListStream => _subject.stream;

  getMediatorList(int requestBackupId) async {
    BackUpMediatorList backUpMediator =
        await _repository.getBackUpMediatorDetails(requestBackupId);
    subject.sink.add(backUpMediator);
  }

  dispose() {
    _subject.close();
  }

  StreamController<BackUpMediatorList> get subject => _subject;
}

final getBackUpMediatorBloc = GetBackUpMediatorBloc();
