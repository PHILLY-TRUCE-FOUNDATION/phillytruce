import 'dart:async';

import 'package:flutter_app/Main/Repository/Mediator/get_user_details_by_id.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:rxdart/rxdart.dart';

class GetUserByIdBloc {
  final GetMediatorByIdRepository _repository = GetMediatorByIdRepository();

  final BehaviorSubject<UserInformationModel> _subject =
      BehaviorSubject<UserInformationModel>();

  getRequestDetails(viewUserId) async {
    UserInformationModel getUserById =
        await _repository.getMediatorByIdDetails(viewUserId);
    subject.sink.add(getUserById);
  }

  dispose() {
    _subject.close();
  }

  StreamController<UserInformationModel> get subject => _subject;
}

final getUserByIdBloc = GetUserByIdBloc();
