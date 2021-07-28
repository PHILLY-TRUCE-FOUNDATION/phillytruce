import 'package:flutter_app/Providers/getMediatorLocation.dart';

class GetMediatorUserLocationRepository {
  GetMediatorsLocationClient getMediatorLocationClient =
      GetMediatorsLocationClient();

  Future getMediatorUserLocationsDetails(helpId) =>
      getMediatorLocationClient.getLocations(helpId);
}
