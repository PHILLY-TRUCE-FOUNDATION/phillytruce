import 'package:flutter_app/Providers/get_user_by_id_provider.dart';

class GetMediatorByIdRepository {
  GetMediatorsByIdClient getMediatorByIdClient = GetMediatorsByIdClient();

  Future getMediatorByIdDetails(viewUserId) => getMediatorByIdClient.getUserById(viewUserId);
}
