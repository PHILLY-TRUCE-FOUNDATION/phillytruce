import 'dart:async';

import 'package:flutter_app/Main/Repository/Mediator/get_location_repository.dart';
import 'package:flutter_app/Model/get_locations.dart';
import 'package:rxdart/rxdart.dart';

class GetMediatorsLocationBloc {
  final GetMediatorUserLocationRepository _repository = GetMediatorUserLocationRepository();

  final BehaviorSubject<GetLocations> _subject =
      BehaviorSubject<GetLocations>();

  getMediatorLocationsDetails(helpId) async {
    GetLocations mediatorDetails =
        await _repository.getMediatorUserLocationsDetails(helpId);
    subject.sink.add(mediatorDetails);
  }

  dispose() {
    _subject.close();
  }

  StreamController<GetLocations> get subject => _subject;
}

final getMediatorsLocationBloc = GetMediatorsLocationBloc();
