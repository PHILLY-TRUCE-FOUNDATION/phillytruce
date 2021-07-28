
import 'package:flutter_app/Widget/progrssIndicator.dart';
class CustomException implements Exception {
  final _message;
  final _prefix;
  final context;

  CustomException([this._message, this._prefix,this.context]);

  String toString() {
    Utils.dismissProgressBar(context);

    return "$_prefix$_message";
  }

}

class FetchDataException extends CustomException {



  FetchDataException([String message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends CustomException {
  InvalidInputException([String message]) : super(message, "Invalid Input: ");
}
