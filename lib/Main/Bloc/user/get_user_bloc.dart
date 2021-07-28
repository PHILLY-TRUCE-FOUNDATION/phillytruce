import 'package:flutter_app/Main/Repository/user_information.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:rxdart/rxdart.dart';

class GetUserBloc {
  final UserInformationRepository _repository = UserInformationRepository();
  final BehaviorSubject<UserInformationModel> _subject =
      BehaviorSubject<UserInformationModel>();

  getUser(int helpId) async {
    UserInformationModel response = await _repository.getUserDetails(helpId);
    _subject.sink.add(response);
  }

  Future<UserInformationModel> getUserForHelpStatus(int helpId) async {
    UserInformationModel response = await _repository.getUserDetails(helpId);
    return response;
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<UserInformationModel> get subject => _subject;
}

final getUserbloc = GetUserBloc();
