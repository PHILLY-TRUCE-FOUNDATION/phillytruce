import 'dart:async';

import 'package:flutter_app/Main/Repository/Mediator/get_mediator_user_repository.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:rxdart/rxdart.dart';

class GetMediatorUserBloc {
  final GetMediatorUserRepository _repository = GetMediatorUserRepository();

  final BehaviorSubject<UserInformationModel> _subject =
      BehaviorSubject<UserInformationModel>();
  final BehaviorSubject<String> _subject1 = BehaviorSubject<String>();

  getMediatorDetails() async {
    UserInformationModel mediatorDetails =
        await _repository.getMediatorUserDetails();
    subject.sink.add(mediatorDetails);
  }

  getIsApprovedornot() async {
    UserInformationModel mediatorDetails =
        await _repository.getMediatorUserDetails();
    subject1.sink.add(mediatorDetails.data.is_approve_mediator);
  }

  dispose() {
    _subject.close();
    _subject1.close();
  }

  StreamController<UserInformationModel> get subject => _subject;

  StreamController<String> get subject1 => _subject1;
}

final getMediatorUserBloc = GetMediatorUserBloc();
