import 'dart:convert';
import 'dart:io';

import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/mediator/add_mediator.dart';
import 'package:flutter_app/Screens/MediatorScreens/mediator_profile_login.dart';
import 'package:flutter_app/Services/firebase.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/checkConnection.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/error_widget.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MediatorRegistration extends StatefulWidget {
  @override
  _MediatorRegistrationState createState() => _MediatorRegistrationState();
}

class _MediatorRegistrationState extends State<MediatorRegistration>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  File _pickedFile;
  String image;

  Position currentPosition;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String pushDeviceToken = '';
  String voIPPushDeviceToken = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      // resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        leading: InkResponse(
          onTap: () => onBackPress(),
          child: Image.asset('assets/images/back_ic.png'),
        ),
        title: TextWidgets().boldTextWidget(
            homeButtonTextColor,
            Strings.appName,
            context,
            ResponsiveFlutter.of(context).fontSize(3.0)),
        shadowColor: Colors.transparent,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Container(
        width: SizeConfig.safeBlockHorizontal * 100,
        height: SizeConfig.safeBlockVertical * 100,
        decoration: backgroundBoxDecoration,
        child: Card(
          margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
          elevation: 1.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.elliptical(
                  ResponsiveFlutter.of(context).hp(2.0),
                  ResponsiveFlutter.of(context).hp(2.0)))),
          child: registrationsForm(),
        ),
      ),
    );
  }

  Future<bool> onBackPress() {
    // Navigator.pop(context);

    // Navigator.pushAndRemoveUntil(
    //     context, MaterialPageRoute(builder: (context) => HomeScreen(),), (
    //     route) => false);

    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // if (Platform.isAndroid) getPermissionStatus();
      // if (Platform.isIOS) getPermissions();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) getPermissionStatus();
    if (Platform.isIOS) getPermissions();

    connectivityCheck().then((bool isAvailable) {
      if (isAvailable) {
        print('wf' + isAvailable.toString());
        getPushToken();
        if (Platform.isIOS) getVoiPPushTokeN();
      } else {
        print('wf' + isAvailable.toString());

        _showAlert(context);
      }
    });
    super.initState();
  }

  void _showAlert(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text("Internet"),
              content: Text("Internet not detected. Please connect it."),
            ));
  }

  Widget registrationsForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextWidgets().semiBoldTextWidget(
                    Colors.red,
                    Strings.confirmationText,
                    context,
                    ResponsiveFlutter.of(context).fontSize(2.0)),
              ),
              if (_pickedFile == null)
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(10.0, 10.0)),
                      image: DecorationImage(
                          image: AssetImage(
                            'assets/images/profile_pic_placeholder.png',
                          ),
                          fit: BoxFit.cover),
                      // image: DecorationImage(fit: BoxFit.fill),
                    ),
                  ),
                  onTap: () => _showSelectionDialog(context),
                ),
              if (_pickedFile != null)
                GestureDetector(
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    margin: EdgeInsets.all(20),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: labelColor),
                        top: BorderSide(color: labelColor),
                        right: BorderSide(color: labelColor),
                        left: BorderSide(color: labelColor),
                      ),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(25.0, 25.0)),
                      // image: DecorationImage(fit: BoxFit.fill),
                    ),
                    child: Image(
                        errorBuilder: (context, child, loadingProgress) {
                          return Container(
                            margin: EdgeInsets.all(20),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(25.0, 25.0)),
                              // image: DecorationImage(fit: BoxFit.fill),
                            ),
                            child: Center(
                              child: Platform.isAndroid
                                  ? CircularProgressIndicator()
                                  : CupertinoActivityIndicator(),
                            ),
                          );
                        },
                        image: FileImage(_pickedFile),
                        fit: BoxFit.cover),
                  ),
                  onTap: () => _showSelectionDialog(context),
                ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: nameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: Strings.name,
                    hintText: Strings.enterName,
                    hintStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
// errorText: _getErrorText(),
                  ),
                  keyboardType: TextInputType.name,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  maxLength: 10,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    return null;
                  },
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(42),
                  ],
                  textCapitalization: TextCapitalization.sentences,
                  controller: mobileNumberController,
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    counter: Offstage(),
                    labelText: Strings.mobileNumber,
                    hintText: Strings.enterMobileNumber,
                    hintStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
// errorText: _getErrorText(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(0.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(0.0)),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    return null;
                    // return value.isValidEmail() ? null : "Check your email";
                  },
                  textCapitalization: TextCapitalization.sentences,
                  controller: emailController,
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: Strings.email,
                    hintText: Strings.enterEmail,
                    hintStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                  controller: password,
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: Strings.password,
                    hintText: Strings.enterPassword,
                    hintStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter confirm password';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                  controller: confirmPassword,
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: Strings.confirmPassword,
                    hintText: Strings.enterConfirmPassword,
                    hintStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please wait while get your location';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                  controller: location,
                  readOnly: true,
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: Strings.location,
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: sendButtonColor,
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(10.0, 10.0))),
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(
                      ResponsiveFlutter.of(context).hp(2.0),
                      ResponsiveFlutter.of(context).hp(1.0),
                      ResponsiveFlutter.of(context).hp(2.0),
                      0),
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Text(
                    Strings.submit,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: fontStyle,
                        fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),
                    textAlign: TextAlign.center,
                  ),
                ),
                onPressed: () {
                  if (_pickedFile != null) {
                    if (_formKey.currentState.validate()) if (password.text
                            .trim()
                            .toString() !=
                        confirmPassword.text.trim().toString()) {
                      showStaticAlertDialog(context,
                          'Password and Confirm password do not match');

                      /*Fluttertoast.showToast(
                          msg: 'Password and Confirm password do not match');*/
                    } else {
                      mediatorRegistrationApiCalling();
                    }
                  } else {
                    showStaticAlertDialog(
                        context, 'Please upload profile picture');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("From where do you want to take the photo?"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Gallery"),
                  onTap: () {
                    Navigator.of(context).pop(false);
                    getImageByGallary();
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text("Camera"),
                  onTap: () {
                    Navigator.of(context).pop(false);
                    getImage();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  mediatorRegistrationApiCalling() async {
    Utils.showProgressBar(context);
    final imageUploadRequest = http.MultipartRequest(
        'POST', Uri.parse(AddMediatorApiClient.addMediatorUrl));

    imageUploadRequest.fields["user_type"] = 'mediator';
    imageUploadRequest.fields["name"] = nameController.text.trim().toString();
    imageUploadRequest.fields["phone_no"] =
        mobileNumberController.text.trim().toString();
    imageUploadRequest.fields["email"] = emailController.text.trim().toString();
    imageUploadRequest.fields["user_latitude"] =
        currentPosition == null
            ? ''
            : currentPosition.latitude.toString();
    imageUploadRequest.fields["user_longitude"] =
        currentPosition == null
            ? ''
            : currentPosition.longitude.toString();
    imageUploadRequest.fields["device_type"] =
        Platform.isAndroid == true ? 'android' : 'ios';
    imageUploadRequest.fields["device_token"] = pushDeviceToken;
    imageUploadRequest.fields["location_name"] =
    location.text == null
            ? ''
            : location.text.trim().toString();
    imageUploadRequest.fields["password"] = password.text.trim().toString();
    imageUploadRequest.fields["voip_token"] =
        Platform.isAndroid ? "" : voIPPushDeviceToken;
    final file = await http.MultipartFile.fromPath('user_profile_pic', image);

    imageUploadRequest.files.add(file);

    try {
      final streamResponse = await imageUploadRequest.send();
      try {
        final response = await http.Response.fromStream(streamResponse).timeout(
          Duration(minutes: 1),
          onTimeout: () {
            print('Flutter Fully Truce' + 'time out');
            Fluttertoast.showToast(
                msg: 'Something went wrong . please try again');
            Utils.dismissProgressBar(context);
            return null;
          },
        ).catchError((onError) {
          Fluttertoast.showToast(
              msg: 'Something went wrong . please try again');
          print('Flutter Fully Truce' + onError.toString());
          Utils.dismissProgressBar(context);
        });

        if (response.statusCode == 200) {
          print("Flutter Fully Truce success" + response.toString());

          UserInformationModel userData =
              UserInformationModel.fromJson(json.decode(response.body));
          if (userData.statusCode == 3) {
            SaveDataLocal.saveUserData(userData);
            Utils.dismissProgressBar(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MediatorRegistrationScreen(true, false),
                ));
          } else {
            Fluttertoast.showToast(msg: userData.message);
            Utils.dismissProgressBar(context);
          }
          // getMediatorUserBloc.getMediatorDetails();
          // setState(() {});
        } else {
          Utils.dismissProgressBar(context);
          Fluttertoast.showToast(
              msg: 'Something went wrong . please try again');
          throw Exception('Exception Handle' + response.reasonPhrase);
        }
      } on SocketException {
        Fluttertoast.showToast(
            msg:
                'Some thing went Wrong to register mediator Please try again later');
        throw FetchDataException('No Internet connection');
      }
    } catch (e) {
      Utils.dismissProgressBar(context);
      return e;
    }
  }

  getPushToken() {
    PushNotificationsManager().pushToken.then((value) {
      pushDeviceToken = value;
      print('Flutter Fully Truce : - ' + value.toString());
    });
  }

  getVoiPPushTokeN() {
    FlutterIOSVoIPKit _voipPush = FlutterIOSVoIPKit();

    _voipPush.requestAuthLocalNotification();

    _voipPush.getVoIPToken().then((value) {
      print('Flutter Fully Truce VoIP Token' + value.toString());
      setState(() {
        voIPPushDeviceToken = value;
      });
    }).catchError((onError) {
      print('Flutter Fully Truce VoIP Token' + onError.toString());
    });
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      currentPosition = position;
      // _getAddressFromLatLng();
    }).catchError((e) {
      print('Flutter Fully Truce' + e.toString());
    });
  }

  _getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    location.text = first.addressLine;
    print("Adrees Lcoation New : - " +
        "${first.featureName} : ${first.addressLine}");
    currentPosition = position;

    // _getCurrentLocation();

  }

  Widget messageScreen() {
    SizeConfig().init(context);
    return Container(
        width: SizeConfig.safeBlockHorizontal * 100,
        height: SizeConfig.safeBlockVertical * 100,
        child: Column(children: [
          new Flexible(
            flex: 2,
            child: Center(
              child: Image.asset('assets/images/philly_truce_text_logo.png'),
            ),
          ),
          new Flexible(
            flex: 6,
            child: Container(
              margin: EdgeInsets.all(0.0),
              width: SizeConfig.safeBlockHorizontal * 100,
              child: Card(
                  margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.elliptical(
                          ResponsiveFlutter.of(context).hp(2.0),
                          ResponsiveFlutter.of(context).hp(2.0)))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(25.0),
                            child: Text(
                              Strings.userConfirmationText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: fontStyle,
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(3.0),
                                color: homeButtonTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FlatButton(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          clipBehavior: Clip.hardEdge,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                                color: sendButtonColor,
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(15.0, 15.0))),
                            alignment: Alignment.bottomCenter,
                            margin: EdgeInsets.fromLTRB(
                                ResponsiveFlutter.of(context).hp(2.0),
                                ResponsiveFlutter.of(context).hp(1.0),
                                ResponsiveFlutter.of(context).hp(2.0),
                                0),
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: Text(
                              Strings.goBackToHome,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: fontStyle,
                                  fontSize: ResponsiveFlutter.of(context)
                                      .fontSize(2.0)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onPressed: () {
                            // Navigator.pushAndRemoveUntil(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => HomeScreen(),
                            //     ),
                            //         (route) => false);
                            Navigator.pop(context);
                            // if (_formKey.currentState.validate()) dialog();
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ]));
  }

  Future getImage() async {
    final pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 350,
        maxHeight: 350);

    setState(() {
      if (pickedFile != null) {
        _pickedFile = File(pickedFile.path);
        image = _pickedFile.path.toString();
        print('Your path is :-' + _pickedFile.path.toString());
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageByGallary() async {
    final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 350,
        maxHeight: 350);

    setState(() {
      if (pickedFile != null) {
        _pickedFile = File(pickedFile.path);
        image = _pickedFile.path.toString();
        print('Your path is :-' + _pickedFile.path.toString());
      } else {
        print('No image selected.');
      }
    });
  }

  getPermissionStatus() async {
    // bool hasBackgroundPermission =
    //     await BackgroundLocation.checkPermissions().isGranted;

    bool isfirstTime = await isFirstTime();
    bool hasPermission = await Permission.location.status.isDenied;
    bool hasPermission1 =
        await Permission.location.serviceStatus.isNotApplicable;
    if (hasPermission ||
        hasPermission1 ||
        // !hasBackgroundPermission ||
        isfirstTime) {
      Future.delayed(Duration(seconds: 1), () => showAlertDialog(context));
    } else {
      _getLocation();
    }
  }

  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isFirstTime = prefs.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      prefs.setBool('first_time', false);
      return false;
    } else {
      prefs.setBool('first_time', false);
      return true;
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
        Future.delayed(Duration(seconds: 2), () {
          getPermissions();
        });
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
        Future.delayed(Duration(seconds: 2), () {
          showAlertDialog(context);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Allow Philly Truce to access your device\'s location.'),
      content: Text(
          "Philly Truce collects location data to enable the location display of user, mediator and backup mediator to each other for help even when the app is closed or not in use."),
      actions: [okButton],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  getPermissions() async {
   // await BackgroundLocation.getPermissions();

    await [
      Permission.location,
    ].request();

    if (await Permission.location.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }
    // if (await Permission.locationAlways.isPermanentlyDenied) {
    //   // The user opted to never again see the permission request dialog for this
    //   // app. The only way to change the permission's status now is to let the
    //   // user manually enable it in the system settings.
    //   openAppSettings();
    // }

    if (await Permission.location.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      getPermissions();
    }
    if (await Permission.location.isGranted) {
      _getLocation();
      // _getCurrentLocation();
    }
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
